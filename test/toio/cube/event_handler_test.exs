defmodule Toio.Cube.EventHandlerTest do
  use ExUnit.Case, async: false

  @moduletag :ble

  alias Toio.{Cube, CubeSupervisor}
  alias Toio.Cube.EventHandler

  setup do
    # Start a test cube
    {:ok, _sup_pid} = CubeSupervisor.start_cube({"test-event-handler", "Test Event Cube"})
    cube = Cube.whereis("test-event-handler")

    on_exit(fn ->
      CubeSupervisor.stop_cube("test-event-handler")
    end)

    {:ok, cube: cube, cube_id: "test-event-handler"}
  end

  describe "attach/3" do
    test "attaches handler successfully", %{cube_id: cube_id} do
      assert :ok = EventHandler.attach(cube_id, :button, fn _event -> :ok end)
    end

    test "handler receives events", %{cube: cube, cube_id: cube_id} do
      test_pid = self()

      EventHandler.attach(cube_id, :button, fn event ->
        send(test_pid, {:handler_called, event})
      end)

      # Simulate button event
      send(cube, {:toio_event, cube, :button, %{pressed: true}})

      assert_receive {:handler_called, %{pressed: true}}, 1000
    end

    test "multiple handlers can be attached", %{cube: cube, cube_id: cube_id} do
      test_pid = self()

      EventHandler.attach(cube_id, :button, fn event ->
        send(test_pid, {:handler1, event})
      end)

      EventHandler.attach(cube_id, :button, fn event ->
        send(test_pid, {:handler2, event})
      end)

      # Simulate button event
      send(cube, {:toio_event, cube, :button, %{pressed: true}})

      assert_receive {:handler1, %{pressed: true}}, 1000
      assert_receive {:handler2, %{pressed: true}}, 1000
    end
  end

  describe "detach/2" do
    test "removes all handlers for event type", %{cube: cube, cube_id: cube_id} do
      test_pid = self()

      EventHandler.attach(cube_id, :button, fn event ->
        send(test_pid, {:handler_called, event})
      end)

      EventHandler.detach(cube_id, :button)

      # Simulate button event
      send(cube, {:toio_event, cube, :button, %{pressed: true}})

      refute_receive {:handler_called, _}, 500
    end
  end

  describe "list_events/1" do
    test "lists active event types", %{cube_id: cube_id} do
      EventHandler.attach(cube_id, :button, fn _event -> :ok end)
      EventHandler.attach(cube_id, :sensor, fn _event -> :ok end)

      events = EventHandler.list_events(cube_id)
      assert :button in events
      assert :sensor in events
    end
  end
end
