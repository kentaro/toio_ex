# Toio Examples

This directory contains example scripts demonstrating various features of the Toio library.

## Running Examples

All examples are Elixir scripts (`.exs` files). Make sure you have a toio Core Cube powered on and nearby before running.

```bash
# Run an example with mix run
mix run examples/basic_movement.exs
```

## Available Examples

### Basic Examples

#### `basic_movement.exs`
Demonstrates basic motor control:
- Moving forward
- Turning
- Moving backward
- Stopping

```bash
mix run examples/basic_movement.exs
```

#### `timed_movement.exs`
Shows time-based motor control using `move_timed/4`:
- Move for a specific duration
- Automatic stopping after the time expires
- Chaining multiple timed movements

```bash
mix run examples/timed_movement.exs
```

#### `position_movement.exs`
⚠️ **Requires toio play mat with position detection**

Demonstrates position-based movement using `move_to/5`:
- Moving to specific coordinates
- Facing specific angles
- Different movement types and speed profiles

```bash
mix run examples/position_movement.exs
```

### Light Control

#### `light_control.exs`
Shows LED control features:
- Turning on specific colors
- Playing light scenarios (rainbow effect)
- Turning off lights

```bash
mix run examples/light_control.exs
```

### Sound Control

#### `sound_control.exs`
Demonstrates sound capabilities:
- Playing built-in sound effects
- Playing MIDI notes
- Playing simple melodies

```bash
mix run examples/sound_control.exs
```

### Multiple Cubes

#### `multiple_cubes.exs`
Shows how to control multiple cubes simultaneously:
- Discovering multiple cubes
- Independent control of each cube
- Synchronized movements

⚠️ **Requires at least 2 toio Core Cubes**

```bash
mix run examples/multiple_cubes.exs
```

### Event Subscription

#### `event_subscription.exs`
Demonstrates event subscription system:
- Button press/release events
- Sensor data events
- Battery status events

```bash
mix run examples/event_subscription.exs
```

### Advanced Examples

#### `low_level_api.exs`
Shows how to use the low-level API directly:
- Manual scanning with `Toio.Scanner`
- Starting cube processes with `Toio.CubeSupervisor`
- Direct calls to `Toio.Cube` functions

```bash
mix run examples/low_level_api.exs
```

#### `interactive_control.exs`
Interactive keyboard control of a toio cube:
- Keyboard-based movement control (WASD)
- LED color selection (1-7 keys)
- Sound effects (P key)

```bash
mix run examples/interactive_control.exs
```

## Example Structure

Most examples follow this pattern:

```elixir
# 1. Discover and connect to cube(s)
{:ok, cubes} = Toio.discover(count: 1, duration: 5000)

case cubes do
  [] ->
    IO.puts("No toio cubes found!")

  [cube | _] ->
    # 2. Control the cube
    Toio.move(cube, 50, 50)
    Process.sleep(2000)

    # 3. Clean up
    Toio.stop(cube)
    IO.puts("Done!")
end
```

## Tips

### Scan Duration
If cubes are not found, try increasing the scan duration:
```elixir
{:ok, cubes} = Toio.discover(duration: 10_000)  # 10 seconds
```

### Connection Wait
After starting a cube process, it may take a few seconds to establish the BLE connection. The examples include appropriate `Process.sleep/1` calls.

### Multiple Cubes
To find multiple cubes, use the `:count` option:
```elixir
{:ok, cubes} = Toio.discover(count: 2, duration: 5000)
```

### Battery Warning
Playing intensive light scenarios or sounds while moving can drain the battery quickly. Consider:
- Shorter durations for light/sound effects
- Lower motor speeds
- Monitoring battery events

## Troubleshooting

### "No toio cubes found!"
1. Make sure your toio Core Cube is powered on (press the button)
2. Ensure the cube is not connected to another device
3. Try increasing scan duration
4. Make sure Bluetooth is enabled on your system

### Connection Timeout
If the cube connects but times out:
1. Move the cube closer to your computer
2. Remove physical obstacles between device and cube
3. Check if other Bluetooth devices are interfering

### Commands Not Working
If the cube doesn't respond to commands:
1. Wait for the initial connection (look for "Successfully connected" log)
2. Ensure the cube has sufficient battery
3. Try disconnecting and reconnecting

## More Information

- [toio™ Core Cube Technical Specification](https://toio.github.io/toio-spec/)
- [Main Documentation](../README.md)
- [API Documentation](https://hexdocs.pm/toio)
