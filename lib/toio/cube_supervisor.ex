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

  This starts both the Cube GenServer and its EventHandler under a
  rest_for_one supervisor. If the Cube crashes, the EventHandler
  will be restarted as well.

  Returns `{:ok, supervisor_pid}` where supervisor_pid is the pid of
  the rest_for_one supervisor managing the cube and its event handler.
  """
  @spec start_cube({String.t(), String.t()}) ::
          DynamicSupervisor.on_start_child()
  def start_cube({id, name} = device) do
    Logger.info("Starting supervised cube process for #{name} (#{id})")

    # Create a Supervisor spec for the cube and its event handler
    # using rest_for_one strategy
    spec = %{
      id: {Toio.Cube, id},
      start:
        {Supervisor, :start_link,
         [
           [
             {Toio.Cube, device},
             {Toio.Cube.EventHandler, {nil, id}}
           ],
           [strategy: :rest_for_one, name: {:via, Registry, {Toio.CubeSupervisorRegistry, id}}]
         ]},
      type: :supervisor,
      restart: :permanent
    }

    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  @doc """
  Stop a cube process and its supervisor.
  """
  @spec stop_cube(String.t()) :: :ok | {:error, :not_found}
  def stop_cube(id) do
    # Look up the supervisor by ID in the CubeSupervisorRegistry
    case Registry.lookup(Toio.CubeSupervisorRegistry, id) do
      [{supervisor_pid, _}] ->
        DynamicSupervisor.terminate_child(__MODULE__, supervisor_pid)

      [] ->
        {:error, :not_found}
    end
  end

  @doc """
  List all running cube processes.

  Returns a list of cube pids (not supervisor or event handler pids).
  """
  @spec list_cubes() :: [pid()]
  def list_cubes do
    # Get all cube pids from the registry, excluding event handlers
    # Event handlers are registered with {:event_handler, cube_id} tuples
    # Cubes are registered with cube_id strings directly
    Registry.select(Toio.CubeRegistry, [
      {{:"$1", :"$2", :_}, [{:is_binary, :"$1"}], [:"$2"]}
    ])
  end

  @impl true
  @spec init(term()) :: {:ok, DynamicSupervisor.sup_flags()}
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
