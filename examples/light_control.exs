
# Light control example
# Demonstrates LED control

# Discover and connect to a toio cube
IO.puts("Scanning for toio cubes...")
{:ok, cubes} = Toio.discover(count: 1, duration: 5000)

case cubes do
  [] ->
    IO.puts("No toio cubes found!")

  [cube | _] ->
    IO.puts("Connected to cube!")

    # Red light
    IO.puts("Red light...")
    Toio.turn_on_light(cube, 255, 0, 0)
    Process.sleep(1000)

    # Green light
    IO.puts("Green light...")
    Toio.turn_on_light(cube, 0, 255, 0)
    Process.sleep(1000)

    # Blue light
    IO.puts("Blue light...")
    Toio.turn_on_light(cube, 0, 0, 255)
    Process.sleep(1000)

    # Light scenario (rainbow effect)
    IO.puts("Playing light scenario...")

    operations = [
      {500, 255, 0, 0},
      # Red
      {500, 255, 127, 0},
      # Orange
      {500, 255, 255, 0},
      # Yellow
      {500, 0, 255, 0},
      # Green
      {500, 0, 0, 255},
      # Blue
      {500, 75, 0, 130},
      # Indigo
      {500, 148, 0, 211}
      # Violet
    ]

    Toio.play_light_scenario(cube, operations, 3)
    Process.sleep(11000)

    # Turn off
    IO.puts("Turning off light...")
    Toio.turn_off_light(cube)

    IO.puts("Done!")
end
