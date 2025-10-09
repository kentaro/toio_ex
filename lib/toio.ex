defmodule Toio do
  @moduledoc """
  Elixir library for controlling toio Core Cubes via Bluetooth Low Energy.

  ## Overview

  This library provides a high-level API for discovering and controlling toio Core Cubes.
  Each cube runs in its own supervised process, allowing you to manage multiple cubes
  simultaneously.

  ## Quick Start

      # Discover and connect to toio cubes
      {:ok, cubes} = Toio.discover()

      # Get the first cube
      [cube | _] = cubes

      # Move forward
      Toio.move(cube, 50, 50)

      # Turn on LED
      Toio.turn_on_light(cube, 255, 0, 0)

      # Play a sound
      Toio.play_sound_effect(cube, :enter)

      # Handle events with pipeable API
      cube
      |> Toio.on(:button, fn event ->
        IO.puts("Button: \#{if event.pressed, do: "pressed", else: "released"}")
      end)

  ## Architecture

  The library is organized as follows:

  - `Toio.Scanner` - Discovers toio cubes via BLE
  - `Toio.Cube` - GenServer managing a single cube connection
  - `Toio.CubeSupervisor` - DynamicSupervisor for cube processes
  - `Toio.Manager` - Manages discovery and automatic cube startup
  - `Toio.Specs.*` - Binary encoding/decoding for BLE characteristics
  - `Toio.Types` - Type definitions for cube data structures
  """

  alias Toio.{Cube, Manager}
  alias Toio.Cube.EventHandler

  @type cube :: pid()
  @type cube_name :: String.t()
  @type rgb :: {0..255, 0..255, 0..255}
  @type speed :: -115..115
  @type duration_ms :: non_neg_integer()
  @type coordinate :: non_neg_integer()
  @type angle :: 0..360
  @type volume :: 0..255
  @type sound_effect ::
          :enter
          | :selected
          | :cancel
          | :cursor
          | :mat_in
          | :mat_out
          | :get1
          | :get2
          | :get3
          | :effect1
          | :effect2

  # Discovery and Management

  @doc """
  Discover toio cubes and start supervised processes for them.

  Discovered cubes are automatically connected and ready to use.

  Options:
    - :duration - scan duration in milliseconds (default: 5000)
    - :count - maximum number of cubes to find (default: :all)

  Returns `{:ok, [pid]}` with a list of cube process IDs.

  ## Examples

      {:ok, cubes} = Toio.discover()
      {:ok, [cube]} = Toio.discover(count: 1)
      {:ok, cubes} = Toio.discover(duration: 10_000)
  """
  @spec discover(keyword()) :: {:ok, [cube()]}
  def discover(opts \\ []) do
    Manager.discover_and_start(opts)
  end

  @doc """
  List all managed cube processes.
  """
  @spec list_cubes() :: [cube()]
  def list_cubes do
    Manager.list_cubes()
  end

  @doc """
  Stop all managed cube processes.
  """
  @spec stop_all() :: :ok
  def stop_all do
    Manager.stop_all_cubes()
  end

  # Connection Management

  @doc """
  Connect to a cube.
  """
  @spec connect(cube(), timeout()) :: :ok | {:error, term()}
  def connect(cube_pid, timeout \\ 10_000) do
    Cube.connect(cube_pid, timeout)
  end

  @doc """
  Disconnect from a cube.
  """
  @spec disconnect(cube()) :: :ok
  def disconnect(cube_pid) do
    Cube.disconnect(cube_pid)
  end

  # Motor Control

  @doc """
  Move the cube motors (pipeable).

  Speed values range from -115 to 115.
  Negative values move backward, positive values move forward.
  Returns the cube pid for chaining.

  ## Examples

      # Move forward
      Toio.move(cube, 50, 50)

      # Turn right
      Toio.move(cube, 50, -50)

      # Stop
      Toio.move(cube, 0, 0)

      # Chain with other operations
      cube
      |> Toio.move(50, 50)
      |> Toio.turn_on_light(0, 255, 0)
  """
  @spec move(cube(), speed(), speed()) :: cube()
  def move(cube_pid, left_speed, right_speed) do
    Cube.move(cube_pid, left_speed, right_speed)
    cube_pid
  end

  @doc """
  Move the cube motors for a specified duration (pipeable).

  Duration is in milliseconds.
  Returns the cube pid for chaining.

  ## Examples

      # Move forward for 1 second
      Toio.move_timed(cube, 50, 50, 1000)
  """
  @spec move_timed(cube(), speed(), speed(), duration_ms()) :: cube()
  def move_timed(cube_pid, left_speed, right_speed, duration_ms) do
    Cube.move_timed(cube_pid, left_speed, right_speed, duration_ms)
    cube_pid
  end

  @doc """
  Move to a target position on the mat (pipeable).

  Options:
    - :timeout - movement timeout in seconds (default: 5)
    - :movement_type - 0: move while rotating, 1: rotate then move, 2: move without rotating (default: 0)
    - :max_speed - maximum speed 10-255 (default: 80)
    - :speed_change_type - 0: constant, 1: slow start, 2: slow end, 3: slow both (default: 0)

  Returns the cube pid for chaining.

  ## Examples

      Toio.move_to(cube, 200, 200, 90)
      Toio.move_to(cube, 200, 200, 90, max_speed: 100, movement_type: 1)
  """
  @spec move_to(cube(), coordinate(), coordinate(), angle(), keyword()) :: cube()
  def move_to(cube_pid, target_x, target_y, target_angle, opts \\ []) do
    Cube.move_to(cube_pid, target_x, target_y, target_angle, opts)
    cube_pid
  end

  @doc """
  Stop motor movement (pipeable).

  Returns the cube pid for chaining.
  """
  @spec stop(cube()) :: cube()
  def stop(cube_pid) do
    Cube.stop(cube_pid)
    cube_pid
  end

  # Light Control

  @doc """
  Turn on the LED light with RGB color (pipeable).

  Duration is in milliseconds. Use 0 for infinite duration.
  Returns the cube pid for chaining.

  ## Examples

      # Red light
      Toio.turn_on_light(cube, 255, 0, 0)

      # Green light for 2 seconds
      Toio.turn_on_light(cube, 0, 255, 0, 2000)

      # Chain with other operations
      cube
      |> Toio.turn_on_light(255, 0, 0)
      |> Toio.move(50, 50)
  """
  @spec turn_on_light(cube(), 0..255, 0..255, 0..255, duration_ms()) :: cube()
  def turn_on_light(cube_pid, r, g, b, duration_ms \\ 0) do
    Cube.turn_on_light(cube_pid, r, g, b, duration_ms)
    cube_pid
  end

  @doc """
  Turn off the LED light (pipeable).

  Returns the cube pid for chaining.
  """
  @spec turn_off_light(cube()) :: cube()
  def turn_off_light(cube_pid) do
    Cube.turn_off_light(cube_pid)
    cube_pid
  end

  @doc """
  Play a light scenario with multiple color changes (pipeable).

  Operations is a list of `{duration_ms, r, g, b}` tuples.
  Returns the cube pid for chaining.

  ## Examples

      operations = [
        {1000, 255, 0, 0},    # Red for 1 second
        {1000, 0, 255, 0},    # Green for 1 second
        {1000, 0, 0, 255}     # Blue for 1 second
      ]
      Toio.play_light_scenario(cube, operations, 3)  # Repeat 3 times
  """
  @spec play_light_scenario(cube(), [{duration_ms(), 0..255, 0..255, 0..255}], non_neg_integer()) ::
          cube()
  def play_light_scenario(cube_pid, operations, repeat_count \\ 0) do
    Cube.play_light_scenario(cube_pid, operations, repeat_count)
    cube_pid
  end

  # Sound Control

  @doc """
  Play a sound effect (pipeable).

  Effect IDs: :enter, :selected, :cancel, :cursor, :mat_in, :mat_out,
              :get1, :get2, :get3, :effect1, :effect2

  Returns the cube pid for chaining.

  ## Examples

      Toio.play_sound_effect(cube, :enter)
      Toio.play_sound_effect(cube, :mat_in, 200)
  """
  @spec play_sound_effect(cube(), sound_effect() | non_neg_integer(), volume()) :: cube()
  def play_sound_effect(cube_pid, effect_id, volume \\ 255) do
    Cube.play_sound_effect(cube_pid, effect_id, volume)
    cube_pid
  end

  @doc """
  Play MIDI notes (pipeable).

  Notes is a list of `{duration_ms, note_number, volume}` tuples.
  Note number 128 is silence. Note 57 = A4 (440 Hz).
  Returns the cube pid for chaining.

  ## Examples

      notes = [
        {300, 60, 255},  # C4
        {300, 64, 255},  # E4
        {300, 67, 255}   # G4
      ]
      Toio.play_midi(cube, notes)
  """
  @spec play_midi(cube(), [{duration_ms(), 0..128, volume()}], non_neg_integer()) :: cube()
  def play_midi(cube_pid, notes, repeat_count \\ 0) do
    Cube.play_midi(cube_pid, notes, repeat_count)
    cube_pid
  end

  @doc """
  Stop sound playback (pipeable).

  Returns the cube pid for chaining.
  """
  @spec stop_sound(cube()) :: cube()
  def stop_sound(cube_pid) do
    Cube.stop_sound(cube_pid)
    cube_pid
  end

  # Event Handling

  @doc """
  Attach an event handler to a cube (pipeable).

  This provides a clean, functional way to handle cube events using
  a callback function. Multiple handlers can be attached to the same
  event type.

  ## Examples

      # Single handler
      cube
      |> Toio.on(:button, fn event ->
        IO.puts("Button pressed: \#{event.pressed}")
      end)

      # Chain multiple handlers
      cube
      |> Toio.on(:button, &handle_button/1)
      |> Toio.on(:sensor, &handle_sensor/1)
      |> Toio.on(:battery, &handle_battery/1)

      # Multiple cubes
      {: ok, [cube1, cube2]} = Toio.discover(count: 2)

      cube1
      |> Toio.turn_on_light(255, 0, 0)
      |> Toio.on(:button, fn _ -> IO.puts("Cube1 pressed!") end)

      cube2
      |> Toio.turn_on_light(0, 0, 255)
      |> Toio.on(:button, fn _ -> IO.puts("Cube2 pressed!") end)
  """
  @spec on(cube(), atom(), (term() -> any())) :: cube()
  def on(cube_pid, event_type, handler) when is_function(handler, 1) do
    EventHandler.attach(cube_pid, event_type, handler)
    cube_pid
  end

  @doc """
  Attach a filtered event handler to a cube (pipeable).

  The filter function is called first. If it returns true, the handler
  is executed.

  ## Examples

      # Only handle button press (not release)
      cube
      |> Toio.on(:button, &(&1.pressed), fn event ->
        IO.puts("Button pressed!")
      end)

      # Handle collisions only
      cube
      |> Toio.on(:sensor, &(&1.collision), fn event ->
        IO.puts("Collision detected!")
      end)

      # Low battery warning
      cube
      |> Toio.on(:battery, &(&1.percentage < 20), fn event ->
        IO.puts("Low battery: \#{event.percentage}%")
      end)
  """
  @spec on(cube(), atom(), (term() -> boolean()), (term() -> any())) :: cube()
  def on(cube_pid, event_type, filter, handler)
      when is_function(filter, 1) and is_function(handler, 1) do
    wrapped_handler = fn event ->
      if filter.(event), do: handler.(event)
    end

    EventHandler.attach(cube_pid, event_type, wrapped_handler)
    cube_pid
  end

  @doc """
  Remove all handlers for a specific event type.

  ## Examples

      Toio.off(cube, :button)
  """
  @spec off(cube(), atom()) :: cube()
  def off(cube_pid, event_type) do
    EventHandler.detach(cube_pid, event_type)
    cube_pid
  end
end
