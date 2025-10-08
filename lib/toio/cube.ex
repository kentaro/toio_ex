defmodule Toio.Cube do
  @moduledoc """
  GenServer for managing a single toio Core Cube connection.

  Each cube runs in its own supervised process, maintaining:
  - BLE connection state
  - Motor control
  - Sensor notifications
  - Automatic reconnection on failure
  """

  use GenServer
  require Logger

  alias RustlerBtleplug.Native
  alias Toio.Constants
  alias Toio.Specs.{LightSpec, MotorSpec, SoundSpec}

  @type cube_id :: String.t()
  @type speed :: -115..115
  @type duration_ms :: non_neg_integer()
  @type coordinate :: non_neg_integer()
  @type angle :: 0..360
  @type volume :: 0..255
  @type sound_effect :: SoundSpec.sound_effect()
  @type event_type :: :id | :sensor | :button | :battery | :motor_response

  defmodule State do
    @moduledoc false
    @type t :: %__MODULE__{
            id: String.t(),
            name: String.t(),
            central: reference(),
            peripheral: reference() | nil,
            connected: boolean(),
            subscribers: map()
          }

    defstruct [
      :id,
      :name,
      :central,
      :peripheral,
      connected: false,
      subscribers: %{}
    ]
  end

  # Client API

  @doc """
  Start a cube GenServer for a given device.
  """
  @spec start_link({cube_id(), String.t()}) :: GenServer.on_start()
  def start_link({id, name}) do
    GenServer.start_link(__MODULE__, {id, name}, name: via_tuple(id))
  end

  @doc """
  Get the process for a cube by ID.
  """
  @spec whereis(cube_id()) :: pid() | nil
  def whereis(id) do
    case Registry.lookup(Toio.CubeRegistry, id) do
      [{pid, _}] -> pid
      [] -> nil
    end
  end

  @doc """
  Move the cube motors.
  left_speed and right_speed: -115 to 115 (negative for backward).
  """
  @spec move(cube_id() | pid(), speed(), speed()) :: :ok | {:error, term()}
  def move(cube_id_or_pid, left_speed, right_speed) do
    GenServer.call(get_pid(cube_id_or_pid), {:move, left_speed, right_speed})
  end

  @doc """
  Stop motor movement.
  """
  @spec stop(cube_id() | pid()) :: :ok | {:error, term()}
  def stop(cube_id_or_pid) do
    move(cube_id_or_pid, 0, 0)
  end

  @doc """
  Disconnect from the cube.
  """
  @spec disconnect(cube_id() | pid()) :: :ok
  def disconnect(cube_id_or_pid) do
    GenServer.call(get_pid(cube_id_or_pid), :disconnect)
  end

  @doc """
  Connect to the cube manually (with timeout).
  """
  @spec connect(cube_id() | pid(), timeout()) :: :ok | {:error, term()}
  def connect(cube_id_or_pid, timeout \\ 10_000) do
    GenServer.call(get_pid(cube_id_or_pid), {:connect, timeout}, timeout + 1000)
  end

  @doc """
  Move the cube motors for a specified duration.
  Duration is in milliseconds.
  """
  @spec move_timed(cube_id() | pid(), speed(), speed(), duration_ms()) :: :ok | {:error, term()}
  def move_timed(cube_id_or_pid, left_speed, right_speed, duration_ms) do
    GenServer.call(get_pid(cube_id_or_pid), {:move_timed, left_speed, right_speed, duration_ms})
  end

  @doc """
  Move to a target position on the mat.

  Options:
    - :timeout - movement timeout in seconds (default: 5)
    - :movement_type - 0: move while rotating, 1: rotate then move, 2: move without rotating (default: 0)
    - :max_speed - maximum speed 10-255 (default: 80)
    - :speed_change_type - 0: constant, 1: slow start, 2: slow end, 3: slow both (default: 0)
  """
  @spec move_to(cube_id() | pid(), coordinate(), coordinate(), angle(), keyword()) ::
          :ok | {:error, term()}
  def move_to(cube_id_or_pid, target_x, target_y, target_angle, opts \\ []) do
    GenServer.call(
      get_pid(cube_id_or_pid),
      {:move_to, target_x, target_y, target_angle, opts}
    )
  end

  @doc """
  Turn on the LED light with RGB color.
  Duration is in milliseconds (0 for infinite).
  """
  @spec turn_on_light(cube_id() | pid(), 0..255, 0..255, 0..255, duration_ms()) ::
          :ok | {:error, term()}
  def turn_on_light(cube_id_or_pid, r, g, b, duration_ms \\ 0) do
    GenServer.call(get_pid(cube_id_or_pid), {:turn_on_light, r, g, b, duration_ms})
  end

  @doc """
  Turn off the LED light.
  """
  @spec turn_off_light(cube_id() | pid()) :: :ok | {:error, term()}
  def turn_off_light(cube_id_or_pid) do
    GenServer.call(get_pid(cube_id_or_pid), :turn_off_light)
  end

  @doc """
  Play a light scenario with multiple color changes.
  Operations is a list of `{duration_ms, r, g, b}` tuples.
  """
  @spec play_light_scenario(
          cube_id() | pid(),
          [{duration_ms(), 0..255, 0..255, 0..255}],
          non_neg_integer()
        ) :: :ok | {:error, term()}
  def play_light_scenario(cube_id_or_pid, operations, repeat_count \\ 0) do
    GenServer.call(get_pid(cube_id_or_pid), {:play_light_scenario, operations, repeat_count})
  end

  @doc """
  Play a sound effect.
  """
  @spec play_sound_effect(cube_id() | pid(), sound_effect() | non_neg_integer(), volume()) ::
          :ok | {:error, term()}
  def play_sound_effect(cube_id_or_pid, effect_id, volume \\ 255) do
    GenServer.call(get_pid(cube_id_or_pid), {:play_sound_effect, effect_id, volume})
  end

  @doc """
  Play MIDI notes.
  Notes is a list of `{duration_ms, note_number, volume}` tuples.
  """
  @spec play_midi(cube_id() | pid(), [{duration_ms(), 0..128, volume()}], non_neg_integer()) ::
          :ok | {:error, term()}
  def play_midi(cube_id_or_pid, notes, repeat_count \\ 0) do
    GenServer.call(get_pid(cube_id_or_pid), {:play_midi, notes, repeat_count})
  end

  @doc """
  Stop sound playback.
  """
  @spec stop_sound(cube_id() | pid()) :: :ok | {:error, term()}
  def stop_sound(cube_id_or_pid) do
    GenServer.call(get_pid(cube_id_or_pid), :stop_sound)
  end

  @doc """
  Subscribe to cube events.
  Events are sent as messages: `{:toio_event, cube_name, event_type, event_data}`
  """
  @spec subscribe(cube_id() | pid(), event_type()) :: :ok
  def subscribe(cube_id_or_pid, event_type) do
    GenServer.call(get_pid(cube_id_or_pid), {:subscribe, event_type, self()})
  end

  @doc """
  Unsubscribe from cube events.
  """
  @spec unsubscribe(cube_id() | pid(), event_type()) :: :ok
  def unsubscribe(cube_id_or_pid, event_type) do
    GenServer.call(get_pid(cube_id_or_pid), {:unsubscribe, event_type, self()})
  end

  # Server Callbacks

  @impl true
  def init({id, name}) do
    Logger.info("Starting cube process for #{name} (#{id})")

    # Create central for this cube
    central =
      case Native.create_central() do
        {:ok, c} -> c
        {:error, reason} -> raise "Failed to create central: #{inspect(reason)}"
        c when is_reference(c) -> c
      end

    state = %State{
      id: id,
      name: name,
      central: central
    }

    # Connect asynchronously
    {:ok, state, {:continue, :connect}}
  end

  @impl true
  def handle_continue(:connect, state) do
    case do_connect(state) do
      {:ok, new_state} ->
        Logger.info("Successfully connected to #{state.name}")
        {:noreply, new_state}

      {:error, reason} ->
        Logger.error("Failed to connect to #{state.name}: #{inspect(reason)}")
        # Retry after 5 seconds
        Process.send_after(self(), :reconnect, 5000)
        {:noreply, state}
    end
  end

  @impl true
  def handle_call({:move, left_speed, right_speed}, _from, state) do
    if state.connected do
      # encode_move returns binary, convert to list for Native.write_characteristic
      command =
        MotorSpec.encode_move(left_speed, right_speed)
        |> :binary.bin_to_list()

      result =
        Native.write_characteristic(
          state.peripheral,
          Constants.motor_uuid(),
          command,
          2000
        )

      case result do
        {:ok, _peripheral} -> {:reply, :ok, state}
        {:error, reason} -> {:reply, {:error, reason}, state}
        p when is_reference(p) -> {:reply, :ok, state}
      end
    else
      {:reply, {:error, :not_connected}, state}
    end
  end

  @impl true
  @spec handle_call(:disconnect, GenServer.from(), State.t()) ::
          {:reply, :ok, State.t()}
  def handle_call(:disconnect, _from, state) do
    if state.connected and state.peripheral do
      Native.disconnect(state.peripheral)
      {:reply, :ok, %{state | connected: false, peripheral: nil}}
    else
      {:reply, :ok, state}
    end
  end

  def handle_call({:connect, timeout}, _from, state) do
    if state.connected do
      {:reply, :ok, state}
    else
      case do_connect(state, timeout) do
        {:ok, new_state} -> {:reply, :ok, new_state}
        {:error, reason} -> {:reply, {:error, reason}, state}
      end
    end
  end

  def handle_call({:move_timed, left_speed, right_speed, duration_ms}, _from, state) do
    if state.connected do
      command =
        MotorSpec.encode_move_timed(left_speed, right_speed, duration_ms) |> :binary.bin_to_list()

      result =
        Native.write_characteristic(state.peripheral, Constants.motor_uuid(), command, 2000)

      case result do
        {:ok, _} -> {:reply, :ok, state}
        {:error, reason} -> {:reply, {:error, reason}, state}
        p when is_reference(p) -> {:reply, :ok, state}
      end
    else
      {:reply, {:error, :not_connected}, state}
    end
  end

  def handle_call({:move_to, target_x, target_y, target_angle, opts}, _from, state) do
    if state.connected do
      command =
        MotorSpec.encode_move_to(target_x, target_y, target_angle, opts) |> :binary.bin_to_list()

      result =
        Native.write_characteristic(state.peripheral, Constants.motor_uuid(), command, 2000)

      case result do
        {:ok, _} -> {:reply, :ok, state}
        {:error, reason} -> {:reply, {:error, reason}, state}
        p when is_reference(p) -> {:reply, :ok, state}
      end
    else
      {:reply, {:error, :not_connected}, state}
    end
  end

  def handle_call({:turn_on_light, r, g, b, duration_ms}, _from, state) do
    if state.connected do
      command = LightSpec.encode_turn_on(r, g, b, duration_ms) |> :binary.bin_to_list()

      result =
        Native.write_characteristic(state.peripheral, Constants.light_uuid(), command, 2000)

      case result do
        {:ok, _} -> {:reply, :ok, state}
        {:error, reason} -> {:reply, {:error, reason}, state}
        p when is_reference(p) -> {:reply, :ok, state}
      end
    else
      {:reply, {:error, :not_connected}, state}
    end
  end

  def handle_call(:turn_off_light, _from, state) do
    if state.connected do
      command = LightSpec.encode_turn_off_all() |> :binary.bin_to_list()

      result =
        Native.write_characteristic(state.peripheral, Constants.light_uuid(), command, 2000)

      case result do
        {:ok, _} -> {:reply, :ok, state}
        {:error, reason} -> {:reply, {:error, reason}, state}
        p when is_reference(p) -> {:reply, :ok, state}
      end
    else
      {:reply, {:error, :not_connected}, state}
    end
  end

  def handle_call({:play_light_scenario, operations, repeat_count}, _from, state) do
    if state.connected do
      command = LightSpec.encode_scenario(operations, repeat_count) |> :binary.bin_to_list()

      result =
        Native.write_characteristic(state.peripheral, Constants.light_uuid(), command, 2000)

      case result do
        {:ok, _} -> {:reply, :ok, state}
        {:error, reason} -> {:reply, {:error, reason}, state}
        p when is_reference(p) -> {:reply, :ok, state}
      end
    else
      {:reply, {:error, :not_connected}, state}
    end
  end

  def handle_call({:play_sound_effect, effect_id, volume}, _from, state) do
    if state.connected do
      command = SoundSpec.encode_play_effect(effect_id, volume) |> :binary.bin_to_list()

      result =
        Native.write_characteristic(state.peripheral, Constants.sound_uuid(), command, 2000)

      case result do
        {:ok, _} -> {:reply, :ok, state}
        {:error, reason} -> {:reply, {:error, reason}, state}
        p when is_reference(p) -> {:reply, :ok, state}
      end
    else
      {:reply, {:error, :not_connected}, state}
    end
  end

  def handle_call({:play_midi, notes, repeat_count}, _from, state) do
    if state.connected do
      command = SoundSpec.encode_play_midi(notes, repeat_count) |> :binary.bin_to_list()

      result =
        Native.write_characteristic(state.peripheral, Constants.sound_uuid(), command, 2000)

      case result do
        {:ok, _} -> {:reply, :ok, state}
        {:error, reason} -> {:reply, {:error, reason}, state}
        p when is_reference(p) -> {:reply, :ok, state}
      end
    else
      {:reply, {:error, :not_connected}, state}
    end
  end

  def handle_call(:stop_sound, _from, state) do
    if state.connected do
      command = SoundSpec.encode_stop() |> :binary.bin_to_list()

      result =
        Native.write_characteristic(state.peripheral, Constants.sound_uuid(), command, 2000)

      case result do
        {:ok, _} -> {:reply, :ok, state}
        {:error, reason} -> {:reply, {:error, reason}, state}
        p when is_reference(p) -> {:reply, :ok, state}
      end
    else
      {:reply, {:error, :not_connected}, state}
    end
  end

  def handle_call({:subscribe, event_type, subscriber_pid}, _from, state) do
    subscribers =
      Map.update(state.subscribers, event_type, [subscriber_pid], &[subscriber_pid | &1])

    # Subscribe to BLE characteristic notifications if not already
    if state.connected do
      uuid = event_type_to_uuid(event_type)
      Native.subscribe(state.peripheral, uuid, 5000)
    end

    {:reply, :ok, %{state | subscribers: subscribers}}
  end

  def handle_call({:unsubscribe, event_type, subscriber_pid}, _from, state) do
    subscribers =
      Map.update(state.subscribers, event_type, [], fn pids ->
        List.delete(pids, subscriber_pid)
      end)

    {:reply, :ok, %{state | subscribers: subscribers}}
  end

  @impl true
  @spec handle_info(:reconnect | tuple(), State.t()) ::
          {:noreply, State.t()}
  def handle_info(:reconnect, state) do
    Logger.info("Attempting to reconnect to #{state.name}...")

    case do_connect(state) do
      {:ok, new_state} ->
        Logger.info("Reconnected to #{state.name}")
        {:noreply, new_state}

      {:error, _reason} ->
        # Retry after 5 seconds
        Process.send_after(self(), :reconnect, 5000)
        {:noreply, state}
    end
  end

  def handle_info({:btleplug_peripheral_disconnected, _}, state) do
    Logger.warning("#{state.name} disconnected, will attempt reconnection")
    Process.send_after(self(), :reconnect, 5000)
    {:noreply, %{state | connected: false, peripheral: nil}}
  end

  def handle_info({:btleplug_characteristic_value_changed, uuid, data}, state) do
    # Handle notifications from toio cube
    Logger.debug("Characteristic #{uuid} changed: #{inspect(data)}")

    # Determine event type and notify subscribers
    event_type = uuid_to_event_type(uuid)

    if event_type do
      subscribers = Map.get(state.subscribers, event_type, [])

      Enum.each(subscribers, fn pid ->
        send(pid, {:toio_event, state.name, event_type, data})
      end)
    end

    {:noreply, state}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

  # Private Functions

  @spec do_connect(State.t(), timeout()) :: {:ok, State.t()} | {:error, term()}
  defp do_connect(state, timeout \\ 10_000) do
    with {:ok, peripheral} <- scan_and_find_peripheral(state),
         {:ok, peripheral} <- connect_peripheral(peripheral, timeout),
         {:ok, state} <- wait_for_connection(state, peripheral, timeout) do
      {:ok, state}
    else
      {:error, reason} -> {:error, reason}
    end
  rescue
    e ->
      Logger.error("Error connecting to #{state.name}: #{inspect(e)}")
      {:error, :connection_failed}
  end

  defp scan_and_find_peripheral(state) do
    # Start scanning
    _central =
      case Native.start_scan(state.central, 3000) do
        {:ok, c} -> c
        {:error, reason} -> raise "Scan failed: #{inspect(reason)}"
        c when is_reference(c) -> c
      end

    # Wait for scan to start
    receive do
      {:btleplug_scan_started, _} -> :ok
    after
      2000 -> :ok
    end

    # Wait for scan to complete
    Process.sleep(3000)
    Native.stop_scan(state.central)

    # Find peripheral
    case Native.find_peripheral(state.central, state.id) do
      {:ok, p} -> {:ok, p}
      {:error, reason} -> raise "Peripheral not found: #{inspect(reason)}"
      p when is_reference(p) -> {:ok, p}
    end
  end

  defp connect_peripheral(peripheral, timeout) do
    case Native.connect(peripheral, timeout) do
      {:ok, p} -> {:ok, p}
      {:error, reason} -> raise "Connection failed: #{inspect(reason)}"
      p when is_reference(p) -> {:ok, p}
    end
  end

  defp wait_for_connection(state, peripheral, timeout) do
    receive do
      {:btleplug_peripheral_connected, _msg} ->
        Logger.debug("Connection confirmed for #{state.name}")
        subscribe_to_motor_notifications(peripheral)
        {:ok, %{state | peripheral: peripheral, connected: true}}
    after
      timeout -> {:error, :connection_timeout}
    end
  end

  defp subscribe_to_motor_notifications(peripheral) do
    case Native.subscribe(peripheral, Constants.motor_uuid(), 5000) do
      {:ok, p} -> p
      {:error, _} -> nil
      p when is_reference(p) -> p
    end
  end

  @spec via_tuple(cube_id()) :: {:via, Registry, {Toio.CubeRegistry, cube_id()}}
  defp via_tuple(id) do
    {:via, Registry, {Toio.CubeRegistry, id}}
  end

  @spec get_pid(cube_id() | pid()) :: pid()
  defp get_pid(pid) when is_pid(pid), do: pid

  defp get_pid(cube_id) when is_binary(cube_id) do
    case whereis(cube_id) do
      nil -> raise ArgumentError, "No cube process found for ID: #{cube_id}"
      pid -> pid
    end
  end

  @spec event_type_to_uuid(event_type()) :: String.t()
  defp event_type_to_uuid(:id), do: Constants.id_uuid()
  defp event_type_to_uuid(:sensor), do: Constants.sensor_uuid()
  defp event_type_to_uuid(:button), do: Constants.button_uuid()
  defp event_type_to_uuid(:battery), do: Constants.battery_uuid()
  defp event_type_to_uuid(:motor_response), do: Constants.motor_uuid()

  @spec uuid_to_event_type(String.t()) :: event_type() | nil
  defp uuid_to_event_type(uuid) do
    cond do
      String.downcase(uuid) == String.downcase(Constants.id_uuid()) -> :id
      String.downcase(uuid) == String.downcase(Constants.sensor_uuid()) -> :sensor
      String.downcase(uuid) == String.downcase(Constants.button_uuid()) -> :button
      String.downcase(uuid) == String.downcase(Constants.battery_uuid()) -> :battery
      String.downcase(uuid) == String.downcase(Constants.motor_uuid()) -> :motor_response
      true -> nil
    end
  end
end
