defmodule Toio.Cube.EventHandler do
  @moduledoc """
  Manages event handlers for a single toio cube.

  Each cube has its own EventHandler process that runs under the same
  supervisor. When the cube dies, the EventHandler dies too and restarts
  with the cube (rest_for_one strategy).
  """
  use GenServer
  require Logger

  @type handler :: (term() -> any())
  @type event_type :: :button | :sensor | :battery | :id | :motor_response

  ## Client API

  @doc """
  Starts the EventHandler for a cube.

  The cube_pid can be nil during initialization (when started by supervisor),
  in which case it will be looked up from the registry after the Cube starts.
  """
  def start_link({cube_pid, cube_id}) do
    GenServer.start_link(__MODULE__, {cube_pid, cube_id}, name: via_tuple(cube_id))
  end

  @doc """
  Attaches a handler function to a specific event type.

  The handler will be called with the event data whenever that event occurs.
  Multiple handlers can be attached to the same event type.

  ## Examples

      Toio.Cube.EventHandler.attach(cube, :button, fn event ->
        IO.puts("Button pressed: \#{event.pressed}")
      end)
  """
  @spec attach(pid() | binary(), event_type(), handler()) :: :ok
  def attach(cube_id_or_pid, event_type, handler) when is_function(handler, 1) do
    cube_id = get_cube_id(cube_id_or_pid)
    GenServer.call(via_tuple(cube_id), {:attach, event_type, handler})
  end

  @doc """
  Detaches all handlers for a specific event type.
  """
  @spec detach(pid() | binary(), event_type()) :: :ok
  def detach(cube_id_or_pid, event_type) do
    cube_id = get_cube_id(cube_id_or_pid)
    GenServer.call(via_tuple(cube_id), {:detach, event_type})
  end

  @doc """
  Lists all active event types that have handlers attached.
  """
  @spec list_events(pid() | binary()) :: [event_type()]
  def list_events(cube_id_or_pid) do
    cube_id = get_cube_id(cube_id_or_pid)
    GenServer.call(via_tuple(cube_id), :list_events)
  end

  ## Server Callbacks

  @impl true
  def init({cube_pid, cube_id}) do
    Logger.debug("Starting EventHandler for cube #{cube_id}")

    # If cube_pid is nil, look it up from registry
    actual_cube_pid =
      cube_pid || wait_for_cube_pid(cube_id)

    # Monitor the cube process
    Process.monitor(actual_cube_pid)

    {:ok, %{cube_pid: actual_cube_pid, cube_id: cube_id, handlers: %{}}}
  end

  @impl true
  def handle_call({:attach, event_type, handler}, _from, state) do
    Logger.debug("Attaching handler for #{event_type} on cube #{state.cube_id}")

    # Subscribe to the event if this is the first handler for this type
    if not Map.has_key?(state.handlers, event_type) do
      Toio.Cube.subscribe(state.cube_pid, event_type)
    end

    # Add handler to the list
    handlers = Map.update(state.handlers, event_type, [handler], &[handler | &1])

    {:reply, :ok, %{state | handlers: handlers}}
  end

  @impl true
  def handle_call({:detach, event_type}, _from, state) do
    Logger.debug("Detaching handlers for #{event_type} on cube #{state.cube_id}")

    # Unsubscribe from the event
    Toio.Cube.unsubscribe(state.cube_pid, event_type)

    # Remove all handlers for this event type
    handlers = Map.delete(state.handlers, event_type)

    {:reply, :ok, %{state | handlers: handlers}}
  end

  @impl true
  def handle_call(:list_events, _from, state) do
    events = Map.keys(state.handlers)
    {:reply, events, state}
  end

  @impl true
  def handle_info({:toio_event, cube_pid, event_type, data}, %{cube_pid: cube_pid} = state) do
    # Execute all handlers for this event type
    state.handlers
    |> Map.get(event_type, [])
    |> Enum.each(fn handler ->
      # Run handler in a separate task to prevent crashes from affecting the EventHandler
      Task.start(fn ->
        try do
          handler.(data)
        rescue
          error ->
            Logger.error("""
            Error in event handler for #{event_type} on cube #{state.cube_id}:
            #{Exception.format(:error, error, __STACKTRACE__)}
            """)
        end
      end)
    end)

    {:noreply, state}
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, cube_pid, reason}, %{cube_pid: cube_pid} = state) do
    Logger.debug("Cube #{state.cube_id} died: #{inspect(reason)}, EventHandler shutting down")
    {:stop, :normal, state}
  end

  ## Private Functions

  defp via_tuple(cube_id) do
    {:via, Registry, {Toio.CubeRegistry, {:event_handler, cube_id}}}
  end

  defp get_cube_id(cube_id) when is_binary(cube_id), do: cube_id

  defp get_cube_id(cube_pid) when is_pid(cube_pid) do
    case Registry.keys(Toio.CubeRegistry, cube_pid) do
      [cube_id | _] -> cube_id
      [] -> raise ArgumentError, "No cube found for pid: #{inspect(cube_pid)}"
    end
  end

  # Wait for the Cube process to register itself
  # This is needed when EventHandler starts before Cube in the supervision tree
  defp wait_for_cube_pid(cube_id, retries \\ 50) do
    case Toio.Cube.whereis(cube_id) do
      nil when retries > 0 ->
        Process.sleep(10)
        wait_for_cube_pid(cube_id, retries - 1)

      nil ->
        raise "Cube #{cube_id} failed to start within timeout"

      pid ->
        pid
    end
  end
end
