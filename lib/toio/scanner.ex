defmodule Toio.Scanner do
  @moduledoc """
  BLE scanner for discovering toio Core Cubes.
  """

  require Logger
  alias RustlerBtleplug.Native
  alias Toio.Constants

  @type scan_option :: {:duration, non_neg_integer()} | {:count, :all | pos_integer()}
  @type toio_device :: {id :: String.t(), name :: String.t()}

  @doc """
  Start a scan for toio cubes.

  Options:
    - :duration - scan duration in milliseconds (default: 5000)
    - :count - maximum number of cubes to find (default: :all)

  Returns a list of {id, name} tuples for discovered toio cubes.
  """
  @spec scan([scan_option()]) :: [toio_device()]
  def scan(opts \\ []) do
    duration = Keyword.get(opts, :duration, 5000)
    count = Keyword.get(opts, :count, :all)

    Logger.info("Starting toio cube scan for #{duration}ms...")

    # Create central and start scanning
    central =
      case Native.create_central() do
        {:ok, c} -> c
        {:error, reason} -> raise "Failed to create central: #{inspect(reason)}"
        c when is_reference(c) -> c
      end

    _central =
      case Native.start_scan(central, duration) do
        {:ok, c} -> c
        {:error, reason} -> raise "Failed to start scan: #{inspect(reason)}"
        c when is_reference(c) -> c
      end

    # Wait for scan started confirmation
    receive do
      {:btleplug_scan_started, _msg} ->
        Logger.debug("Scan started successfully")
    after
      1000 ->
        Logger.warning("Scan start timeout")
    end

    # Wait for scan duration
    Process.sleep(duration)

    # Stop scanning
    Native.stop_scan(central)

    # Get all discovered peripherals
    state = Native.get_adapter_state_map(central)
    peripherals = state.peripherals

    # Filter for toio cubes (peripherals is a list, not a map)
    toio_cubes =
      peripherals
      |> Enum.filter(fn info ->
        info.name && String.starts_with?(info.name, Constants.advertisement_prefix())
      end)
      |> Enum.map(fn info ->
        Logger.info("Found toio cube: #{info.name} (#{info.id})")
        {info.id, info.name}
      end)
      |> limit_results(count)

    Logger.info("Found #{length(toio_cubes)} toio cube(s)")
    toio_cubes
  end

  # Private functions

  @spec limit_results([toio_device()], :all | non_neg_integer()) :: [toio_device()]
  defp limit_results(_devices, 0), do: []
  defp limit_results(devices, :all), do: devices

  defp limit_results(devices, count) when is_integer(count) and count > 0 do
    Enum.take(devices, count)
  end
end
