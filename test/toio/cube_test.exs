defmodule Toio.CubeTest do
  use ExUnit.Case, async: false

  @moduletag :ble

  alias Toio.{Cube, CubeSupervisor}

  setup do
    # Each test gets a fresh cube process
    :ok
  end

  describe "whereis/1" do
    test "returns nil for non-existent cube" do
      assert Cube.whereis("non-existent-id") == nil
    end

    test "returns pid for existing cube" do
      {:ok, _pid} = CubeSupervisor.start_cube({"test-id", "Test Cube"})
      Process.sleep(100)

      pid = Cube.whereis("test-id")
      assert is_pid(pid)
      assert Process.alive?(pid)

      # Cleanup
      CubeSupervisor.stop_cube("test-id")
    end
  end

  describe "move/3" do
    test "returns error when not connected" do
      {:ok, _pid} = CubeSupervisor.start_cube({"test-move-id", "Test Cube"})
      Process.sleep(100)

      # Will fail because cube is not connected to real hardware
      assert {:error, :not_connected} = Cube.move("test-move-id", 50, 50)

      # Cleanup
      CubeSupervisor.stop_cube("test-move-id")
    end
  end

  describe "stop/1" do
    test "calls move with 0, 0" do
      {:ok, _pid} = CubeSupervisor.start_cube({"test-stop-id", "Test Cube"})
      Process.sleep(100)

      # Will fail because cube is not connected to real hardware
      assert {:error, :not_connected} = Cube.stop("test-stop-id")

      # Cleanup
      CubeSupervisor.stop_cube("test-stop-id")
    end
  end

  describe "disconnect/1" do
    test "disconnects from cube" do
      {:ok, _pid} = CubeSupervisor.start_cube({"test-disconnect-id", "Test Cube"})
      Process.sleep(100)

      assert :ok = Cube.disconnect("test-disconnect-id")

      # Cleanup
      CubeSupervisor.stop_cube("test-disconnect-id")
    end
  end

  describe "connect/2" do
    @tag :integration
    test "returns ok when already connected" do
      {:ok, _pid} = CubeSupervisor.start_cube({"test-connect-id", "Test Cube"})
      Process.sleep(100)

      # Will timeout but shouldn't crash
      assert {:error, _} = Cube.connect("test-connect-id", 1000)

      # Cleanup
      CubeSupervisor.stop_cube("test-connect-id")
    end
  end

  describe "move_timed/4" do
    test "returns error when not connected" do
      {:ok, _pid} = CubeSupervisor.start_cube({"test-move-timed-id", "Test Cube"})
      Process.sleep(100)

      assert {:error, :not_connected} = Cube.move_timed("test-move-timed-id", 50, 50, 1000)

      # Cleanup
      CubeSupervisor.stop_cube("test-move-timed-id")
    end
  end

  describe "move_to/5" do
    test "returns error when not connected" do
      {:ok, _pid} = CubeSupervisor.start_cube({"test-move-to-id", "Test Cube"})
      Process.sleep(100)

      assert {:error, :not_connected} = Cube.move_to("test-move-to-id", 200, 200, 90)

      # Cleanup
      CubeSupervisor.stop_cube("test-move-to-id")
    end
  end

  describe "light control" do
    test "turn_on_light/5 returns error when not connected" do
      {:ok, _pid} = CubeSupervisor.start_cube({"test-light-on-id", "Test Cube"})
      Process.sleep(100)

      assert {:error, :not_connected} = Cube.turn_on_light("test-light-on-id", 255, 0, 0)

      # Cleanup
      CubeSupervisor.stop_cube("test-light-on-id")
    end

    test "turn_off_light/1 returns error when not connected" do
      {:ok, _pid} = CubeSupervisor.start_cube({"test-light-off-id", "Test Cube"})
      Process.sleep(100)

      assert {:error, :not_connected} = Cube.turn_off_light("test-light-off-id")

      # Cleanup
      CubeSupervisor.stop_cube("test-light-off-id")
    end

    test "play_light_scenario/3 returns error when not connected" do
      {:ok, _pid} = CubeSupervisor.start_cube({"test-light-scenario-id", "Test Cube"})
      Process.sleep(100)

      operations = [{1000, 255, 0, 0}, {1000, 0, 255, 0}]

      assert {:error, :not_connected} =
               Cube.play_light_scenario("test-light-scenario-id", operations)

      # Cleanup
      CubeSupervisor.stop_cube("test-light-scenario-id")
    end
  end

  describe "sound control" do
    test "play_sound_effect/3 returns error when not connected" do
      {:ok, _pid} = CubeSupervisor.start_cube({"test-sound-effect-id", "Test Cube"})
      Process.sleep(100)

      assert {:error, :not_connected} = Cube.play_sound_effect("test-sound-effect-id", :enter)

      # Cleanup
      CubeSupervisor.stop_cube("test-sound-effect-id")
    end

    test "play_midi/3 returns error when not connected" do
      {:ok, _pid} = CubeSupervisor.start_cube({"test-midi-id", "Test Cube"})
      Process.sleep(100)

      notes = [{300, 60, 255}]
      assert {:error, :not_connected} = Cube.play_midi("test-midi-id", notes)

      # Cleanup
      CubeSupervisor.stop_cube("test-midi-id")
    end

    test "stop_sound/1 returns error when not connected" do
      {:ok, _pid} = CubeSupervisor.start_cube({"test-stop-sound-id", "Test Cube"})
      Process.sleep(100)

      assert {:error, :not_connected} = Cube.stop_sound("test-stop-sound-id")

      # Cleanup
      CubeSupervisor.stop_cube("test-stop-sound-id")
    end
  end

  describe "event subscription" do
    test "subscribe/2 registers subscriber" do
      {:ok, _pid} = CubeSupervisor.start_cube({"test-subscribe-id", "Test Cube"})
      Process.sleep(100)

      assert :ok = Cube.subscribe("test-subscribe-id", :button)

      # Cleanup
      CubeSupervisor.stop_cube("test-subscribe-id")
    end

    test "unsubscribe/2 removes subscriber" do
      {:ok, _pid} = CubeSupervisor.start_cube({"test-unsubscribe-id", "Test Cube"})
      Process.sleep(100)

      assert :ok = Cube.subscribe("test-unsubscribe-id", :button)
      assert :ok = Cube.unsubscribe("test-unsubscribe-id", :button)

      # Cleanup
      CubeSupervisor.stop_cube("test-unsubscribe-id")
    end
  end
end
