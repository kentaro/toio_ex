defmodule Toio.ManagerTest do
  use ExUnit.Case, async: false

  alias Toio.{CubeSupervisor, Manager}

  setup do
    # Clean up any existing cubes
    Manager.stop_all_cubes()
    Process.sleep(100)
    :ok
  end

  describe "discover_and_start/1" do
    test "returns empty list when no cubes found" do
      # Very short scan duration to ensure no cubes are found
      assert {:ok, []} = Manager.discover_and_start(duration: 100, count: 0)
    end

    # Note: Testing with real cubes requires hardware
    # This test is a placeholder for integration testing
  end

  describe "list_cubes/0" do
    test "returns empty list when no cubes running" do
      Manager.stop_all_cubes()
      Process.sleep(100)

      assert Manager.list_cubes() == []
    end

    test "returns list of running cubes" do
      {:ok, _pid1} = CubeSupervisor.start_cube({"test-manager-1", "Test Cube 1"})
      {:ok, _pid2} = CubeSupervisor.start_cube({"test-manager-2", "Test Cube 2"})
      Process.sleep(100)

      cubes = Manager.list_cubes()
      assert length(cubes) >= 2

      # Cleanup
      Manager.stop_all_cubes()
    end
  end

  describe "stop_all_cubes/0" do
    test "stops all running cubes" do
      {:ok, _pid1} = CubeSupervisor.start_cube({"test-stop-1", "Test Cube 1"})
      {:ok, _pid2} = CubeSupervisor.start_cube({"test-stop-2", "Test Cube 2"})
      Process.sleep(100)

      assert length(Manager.list_cubes()) >= 2

      assert :ok = Manager.stop_all_cubes()
      Process.sleep(100)

      assert Manager.list_cubes() == []
    end

    test "returns :ok when no cubes running" do
      Manager.stop_all_cubes()
      Process.sleep(100)

      assert :ok = Manager.stop_all_cubes()
    end
  end
end
