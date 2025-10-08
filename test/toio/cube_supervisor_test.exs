defmodule Toio.CubeSupervisorTest do
  use ExUnit.Case, async: false

  @moduletag :ble

  alias Toio.{Cube, CubeSupervisor}

  describe "start_cube/1" do
    test "starts a cube process under supervision" do
      {:ok, pid} = CubeSupervisor.start_cube({"test-id-1", "Test Cube 1"})

      assert is_pid(pid)
      assert Process.alive?(pid)

      # Cleanup
      CubeSupervisor.stop_cube("test-id-1")
    end

    test "registers cube with the registry" do
      {:ok, _pid} = CubeSupervisor.start_cube({"test-id-2", "Test Cube 2"})
      Process.sleep(100)

      registered_pid = Cube.whereis("test-id-2")
      assert is_pid(registered_pid)

      # Cleanup
      CubeSupervisor.stop_cube("test-id-2")
    end
  end

  describe "stop_cube/1" do
    test "stops a running cube process" do
      {:ok, pid} = CubeSupervisor.start_cube({"test-id-3", "Test Cube 3"})
      assert Process.alive?(pid)

      assert :ok = CubeSupervisor.stop_cube("test-id-3")
      Process.sleep(100)

      assert Cube.whereis("test-id-3") == nil
    end

    test "returns error for non-existent cube" do
      assert {:error, :not_found} = CubeSupervisor.stop_cube("non-existent")
    end
  end

  describe "list_cubes/0" do
    test "returns empty list when no cubes running" do
      # Stop all cubes first
      CubeSupervisor.list_cubes()
      |> Enum.each(fn pid ->
        DynamicSupervisor.terminate_child(CubeSupervisor, pid)
      end)

      Process.sleep(100)

      assert CubeSupervisor.list_cubes() == []
    end

    test "returns list of running cube pids" do
      {:ok, pid1} = CubeSupervisor.start_cube({"test-id-4", "Test Cube 4"})
      {:ok, pid2} = CubeSupervisor.start_cube({"test-id-5", "Test Cube 5"})

      cubes = CubeSupervisor.list_cubes()

      assert pid1 in cubes
      assert pid2 in cubes
      assert length(cubes) >= 2

      # Cleanup
      CubeSupervisor.stop_cube("test-id-4")
      CubeSupervisor.stop_cube("test-id-5")
    end
  end
end
