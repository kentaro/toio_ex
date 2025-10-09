# Toio

Elixir library for controlling [toio™ Core Cubes](https://toio.io/) via Bluetooth Low Energy.

This library provides a high-level API for discovering and controlling toio Core Cubes. Each cube runs in its own supervised process, allowing you to manage multiple cubes simultaneously.

## Features

- 🔍 **Auto-discovery** - Automatically scan for and connect to toio cubes
- 🎮 **Motor Control** - Move, rotate, and navigate to specific positions
- 💡 **LED Control** - Control the RGB LED with colors and light scenarios
- 🔊 **Sound** - Play sound effects and MIDI melodies
- 📡 **Event System** - Subscribe to button, sensor, battery, and position events
- 🔄 **Multi-cube** - Control multiple cubes simultaneously with process-based architecture
- 🛡️ **Fault Tolerant** - Each cube runs under a supervisor for resilience

## Installation

Add `toio` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:toio, github: "kentaro/toio_ex"}
  ]
end
```

Once published to Hex, you can use:

```elixir
def deps do
  [
    {:toio, "~> 0.1.0"}
  ]
end
```

## Quick Start

```elixir
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

# Handle button events
cube
|> Toio.on(:button, fn event ->
  IO.puts("Button: #{if event.pressed, do: "pressed", else: "released"}")
end)
```

## Usage Examples

### Discover Cubes

```elixir
# Discover all cubes (scan for 5 seconds by default)
{:ok, cubes} = Toio.discover()

# Discover just one cube
{:ok, [cube]} = Toio.discover(count: 1)

# Scan for 10 seconds
{:ok, cubes} = Toio.discover(duration: 10_000)
```

### Motor Control

```elixir
# Move forward
Toio.move(cube, 50, 50)

# Turn right (left motor forward, right motor backward)
Toio.move(cube, 50, -50)

# Move for 2 seconds then stop automatically
Toio.move_timed(cube, 50, 50, 2000)

# Move to a specific position on the mat
Toio.move_to(cube, 200, 200, 90)

# Stop
Toio.stop(cube)
```

### LED Control

```elixir
# Turn on red light
Toio.turn_on_light(cube, 255, 0, 0)

# Green light for 2 seconds
Toio.turn_on_light(cube, 0, 255, 0, 2000)

# Rainbow effect
operations = [
  {500, 255, 0, 0},    # Red
  {500, 255, 127, 0},  # Orange
  {500, 255, 255, 0},  # Yellow
  {500, 0, 255, 0},    # Green
  {500, 0, 0, 255},    # Blue
  {500, 75, 0, 130},   # Indigo
  {500, 148, 0, 211}   # Violet
]
Toio.play_light_scenario(cube, operations, 3)  # Repeat 3 times

# Turn off
Toio.turn_off_light(cube)
```

### Sound Control

```elixir
# Play sound effects
Toio.play_sound_effect(cube, :enter)
Toio.play_sound_effect(cube, :mat_in, 200)  # With volume

# Play MIDI notes (C major scale)
notes = [
  {300, 60, 255},  # C4
  {300, 62, 255},  # D4
  {300, 64, 255},  # E4
  {300, 65, 255},  # F4
  {300, 67, 255},  # G4
  {300, 69, 255},  # A4
  {300, 71, 255},  # B4
  {300, 72, 255}   # C5
]
Toio.play_midi(cube, notes)

# Stop sound
Toio.stop_sound(cube)
```

### Event Handling

The library provides a clean, pipeable API for handling cube events:

```elixir
# Attach event handlers using the pipe operator
cube
|> Toio.on(:button, fn event ->
  IO.puts("Button: #{if event.pressed, do: "pressed", else: "released"}")
end)
|> Toio.on(:sensor, fn event ->
  if event.collision, do: IO.puts("Collision!")
end)
|> Toio.on(:battery, fn event ->
  IO.puts("Battery: #{event.percentage}%")
end)

# Use filtered handlers for specific conditions
cube
|> Toio.on(:button, & &1.pressed, fn _ ->
  IO.puts("Button pressed (filtered)")
end)
|> Toio.on(:battery, &(&1.percentage < 20), fn event ->
  IO.puts("Low battery: #{event.percentage}%")
end)

# Remove handlers
Toio.off(cube, :button)
```

Event types:
- `:button` - Button press/release
- `:sensor` - Motion, collision, double-tap detection
- `:battery` - Battery level updates
- `:id` - Position and Standard ID information
- `:motor_response` - Motor command responses

### Multiple Cubes

```elixir
# Discover multiple cubes
{:ok, [cube1, cube2]} = Toio.discover(count: 2)

# Control them independently
Toio.turn_on_light(cube1, 255, 0, 0)  # Red
Toio.turn_on_light(cube2, 0, 0, 255)  # Blue

Toio.move(cube1, 50, 50)   # Both move forward
Toio.move(cube2, 50, 50)

# Make them dance!
Task.async(fn ->
  Toio.move(cube1, 50, -50)  # Spin right
end)

Task.async(fn ->
  Toio.move(cube2, -50, 50)  # Spin left
end)
```

## Architecture

The library is organized with a process-based architecture:

- **Toio.Scanner** - Discovers toio cubes via BLE scanning
- **Toio.Cube** - GenServer managing a single cube connection
- **Toio.CubeSupervisor** - DynamicSupervisor for cube processes
- **Toio.Manager** - Manages discovery and automatic cube process startup
- **Toio.Specs.\*** - Binary encoding/decoding for BLE characteristics
- **Toio.Types** - Type definitions for cube data structures

Each discovered cube runs in its own supervised GenServer process, providing:
- Isolation: One cube crashing won't affect others
- Concurrency: Control multiple cubes simultaneously
- Fault tolerance: Automatic restart on failures

## Examples

See the `examples/` directory for complete working examples:

- `basic_movement.exs` - Basic motor control
- `light_control.exs` - LED control and scenarios
- `sound_control.exs` - Sound effects and MIDI playback
- `event_subscription.exs` - Subscribing to cube events
- `multiple_cubes.exs` - Controlling multiple cubes

Run examples with:

```bash
mix run examples/basic_movement.exs
```

## API Reference

### Discovery & Management

- `Toio.discover/1` - Discover and connect to cubes
- `Toio.list_cubes/0` - List all managed cube processes
- `Toio.stop_all/0` - Stop all cube processes

### Connection

- `Toio.connect/2` - Connect to a cube
- `Toio.disconnect/1` - Disconnect from a cube

### Motor Control

- `Toio.move/3` - Move with left/right motor speeds
- `Toio.move_timed/4` - Move for a duration
- `Toio.move_to/5` - Move to target position on mat
- `Toio.stop/1` - Stop movement

### LED Control

- `Toio.turn_on_light/5` - Turn on LED with RGB color
- `Toio.turn_off_light/1` - Turn off LED
- `Toio.play_light_scenario/3` - Play light animation

### Sound Control

- `Toio.play_sound_effect/3` - Play predefined sound
- `Toio.play_midi/3` - Play MIDI notes
- `Toio.stop_sound/1` - Stop sound playback

### Event Handling

- `Toio.on/3` - Attach event handler (pipeable)
- `Toio.on/4` - Attach filtered event handler (pipeable)
- `Toio.off/2` - Remove event handlers

## Sound Effect IDs

Available sound effects:
- `:enter` - Enter sound
- `:selected` - Selection sound
- `:cancel` - Cancel sound
- `:cursor` - Cursor movement
- `:mat_in` - On mat detection
- `:mat_out` - Off mat detection
- `:get1`, `:get2`, `:get3` - Collection sounds
- `:effect1`, `:effect2` - Generic effects

## Requirements

- Elixir >= 1.18
- macOS, Linux, or Windows with BLE support
- toio Core Cube (BLE 4.2)
- [rustler_btleplug](https://hex.pm/packages/rustler_btleplug) for BLE communication

## License

Apache License 2.0

## References

- [toio™ Official Website](https://toio.io/)
- [toio™ Technical Specifications](https://toio.github.io/toio-spec/)
- [toio.js](https://github.com/toio/toio.js) - Official JavaScript library

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
