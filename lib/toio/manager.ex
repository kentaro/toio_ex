defmodule Toio.Manager do
  @moduledoc """
  High-level manager for discovering and managing multiple toio cubes.
  """

  require Logger
  alias Toio.{CubeSupervisor, Scanner}

  @type cube :: pid()

  @doc """
  Discover toio cubes and start supervised processes for them.

  Options:
    - :duration - scan duration in milliseconds (default: 5000)
    - :count - maximum number of cubes to find (default: :all)
    - :auto_connect - automatically connect to discovered cubes (default: true)

  Returns `{:ok, [pid]}` with a list of cube process IDs.
  """
  @spec discover_and_start(keyword()) :: {:ok, [cube()]}
  def discover_and_start(opts \\ []) do
    duration = Keyword.get(opts, :duration, 5000)
    count = Keyword.get(opts, :count, :all)

    Logger.info("Discovering toio cubes...")
    devices = Scanner.scan(duration: duration, count: count)

    devices
    |> handle_discovered_devices()
  end

  defp handle_discovered_devices([]) do
    Logger.warning("No toio cubes found")
    {:ok, []}
  end

  defp handle_discovered_devices(devices) do
    pids =
      devices
      |> Enum.map(&start_cube_process/1)
      |> Enum.filter(&is_pid/1)

    {:ok, pids}
  end

  defp start_cube_process({id, _name} = device) do
    case CubeSupervisor.start_cube(device) do
      {:ok, _supervisor_pid} ->
        # The supervisor pid is not the cube pid - look up the actual cube process
        cube_pid = Toio.Cube.whereis(id)
        Logger.info("Started cube process: #{inspect(cube_pid)}")
        cube_pid

      {:error, {:already_started, _supervisor_pid}} ->
        # Look up the actual cube process
        cube_pid = Toio.Cube.whereis(id)
        Logger.info("Cube already running: #{inspect(cube_pid)}")
        cube_pid

      {:error, reason} ->
        Logger.error("Failed to start cube: #{inspect(reason)}")
        nil
    end
  end

  @doc """
  List all managed cube processes.
  """
  @spec list_cubes() :: [cube()]
  def list_cubes do
    CubeSupervisor.list_cubes()
  end

  @doc """
  Stop all managed cube processes.
  """
  @spec stop_all_cubes() :: :ok
  def stop_all_cubes do
    # Get all cube IDs from registry
    Registry.select(Toio.CubeRegistry, [{{:"$1", :_, :_}, [], [:"$1"]}])
    |> Enum.each(&CubeSupervisor.stop_cube/1)

    :ok
  end
end
