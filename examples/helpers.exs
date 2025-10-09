# Helper functions for examples

defmodule ExampleHelpers do
  @moduledoc """
  Common helper functions for toio examples.
  """

  @doc """
  Discovers a single cube with error handling.
  Returns the cube pid or exits with error code 1.
  """
  def discover_one_cube!(duration \\ 5000) do
    IO.puts("Scanning for toio cubes...")

    case Toio.discover(count: 1, duration: duration) do
      {:ok, []} ->
        IO.puts("No toio cubes found!")
        System.halt(1)

      {:ok, [cube | _]} ->
        IO.puts("Connected to cube!")
        cube

      {:error, reason} ->
        IO.puts("Failed to discover cubes: #{inspect(reason)}")
        System.halt(1)
    end
  end

  @doc """
  Runs a function with a cube and ensures proper cleanup.
  """
  def with_cube(cube, fun) do
    try do
      fun.(cube)
    after
      Toio.stop(cube)
      Toio.disconnect(cube)
    end
  end

  @doc """
  Pattern matches on :ok or raises with error message.
  """
  def assert_ok!(:ok), do: :ok

  def assert_ok!({:error, reason}) do
    raise "Command failed: #{inspect(reason)}"
  end
end
