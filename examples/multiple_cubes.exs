
# Multiple cubes example
# Demonstrates controlling multiple toio cubes simultaneously

# Discover and connect to multiple toio cubes
IO.puts("Scanning for toio cubes...")
{:ok, cubes} = Toio.discover(count: 2, duration: 5000)

case cubes do
  [] ->
    IO.puts("No toio cubes found!")

  [cube1] ->
    IO.puts("Found 1 cube. Need at least 2 cubes for this example.")

  [cube1, cube2 | _] ->
    IO.puts("Found 2 cubes! Let's make them dance!")

    # Turn on different colored lights
    IO.puts("Cube 1: Red light")
    Toio.turn_on_light(cube1, 255, 0, 0)

    IO.puts("Cube 2: Blue light")
    Toio.turn_on_light(cube2, 0, 0, 255)

    Process.sleep(2000)

    # Move both cubes forward
    IO.puts("Both cubes moving forward...")
    Toio.move(cube1, 50, 50)
    Toio.move(cube2, 50, 50)
    Process.sleep(2000)

    # Stop both
    IO.puts("Stopping...")
    Toio.stop(cube1)
    Toio.stop(cube2)
    Process.sleep(1000)

    # Make them turn in opposite directions
    IO.puts("Cube 1: Turning right, Cube 2: Turning left")
    Toio.move(cube1, 50, -50)
    Toio.move(cube2, -50, 50)
    Process.sleep(2000)

    # Stop both
    IO.puts("Stopping...")
    Toio.stop(cube1)
    Toio.stop(cube2)

    # Play different sounds
    IO.puts("Playing sounds...")
    Toio.play_sound_effect(cube1, :enter)
    Process.sleep(500)
    Toio.play_sound_effect(cube2, :mat_in)

    Process.sleep(1000)

    # Turn off lights
    Toio.turn_off_light(cube1)
    Toio.turn_off_light(cube2)

    IO.puts("Done!")
end
