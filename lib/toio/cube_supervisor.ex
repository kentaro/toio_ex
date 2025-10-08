defmodule Toio.CubeSupervisor do
  @moduledoc """
  DynamicSupervisor for managing toio cube processes.

  Supervises individual Toio.Cube GenServers, allowing:
  - Dynamic addition of cubes as they're discovered
  - Automatic restart on crashes
  - Independent lifecycle management per cube
  """

  use DynamicSupervisor
  require Logger

  @doc """
  Start the cube supervisor.
  """
  @spec start_link(term()) :: Supervisor.on_start()
  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @doc """
  Start a cube process under supervision.
  """
  @spec start_cube({String.t(), String.t()}) ::
          DynamicSupervisor.on_start_child()
  def start_cube({id, name} = device) do
    Logger.info("Starting supervised cube process for #{name} (#{id})")

    spec = {Toio.Cube, device}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  @doc """
  Stop a cube process.
  """
  @spec stop_cube(String.t()) :: :ok | {:error, :not_found}
  def stop_cube(id) do
    case Toio.Cube.whereis(id) do
      nil ->
        {:error, :not_found}

      pid ->
        DynamicSupervisor.terminate_child(__MODULE__, pid)
    end
  end

  @doc """
  List all running cube processes.
  """
  @spec list_cubes() :: [pid()]
  def list_cubes do
    DynamicSupervisor.which_children(__MODULE__)
    |> Enum.map(fn {_, pid, _, _} -> pid end)
    |> Enum.filter(&is_pid/1)
  end

  @impl true
  @spec init(term()) :: {:ok, DynamicSupervisor.sup_flags()}
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
