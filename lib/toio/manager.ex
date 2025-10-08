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
  @spec discover_and_start(keyword()) :: {:ok, [cube()]} | {:error, term()}
  def discover_and_start(opts \\ []) do
    duration = Keyword.get(opts, :duration, 5000)
    count = Keyword.get(opts, :count, :all)

    Logger.info("Discovering toio cubes...")

    # Scan for cubes
    devices = Scanner.scan(duration: duration, count: count)

    if Enum.empty?(devices) do
      Logger.warning("No toio cubes found")
      {:ok, []}
    else
      # Start supervised processes for each cube
      pids =
        devices
        |> Enum.map(fn device ->
          case CubeSupervisor.start_cube(device) do
            {:ok, pid} ->
              Logger.info("Started cube process: #{inspect(pid)}")
              pid

            {:error, {:already_started, pid}} ->
              Logger.info("Cube already running: #{inspect(pid)}")
              pid

            {:error, reason} ->
              Logger.error("Failed to start cube: #{inspect(reason)}")
              nil
          end
        end)
        |> Enum.filter(&is_pid/1)

      {:ok, pids}
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
    list_cubes()
    |> Enum.each(fn pid ->
      # Get cube ID from registry to stop properly
      case Registry.keys(Toio.CubeRegistry, pid) do
        [id | _] ->
          CubeSupervisor.stop_cube(id)

        [] ->
          # Fallback: terminate directly
          DynamicSupervisor.terminate_child(CubeSupervisor, pid)
      end
    end)

    :ok
  end
end
