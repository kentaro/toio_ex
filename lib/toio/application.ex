defmodule Toio.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Registry for cube process lookup by ID
      {Registry, keys: :unique, name: Toio.CubeRegistry},
      # DynamicSupervisor for managing cube processes
      Toio.CubeSupervisor
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Toio.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
