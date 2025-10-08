
# Timed movement example
# Demonstrates time-based motor control

# Discover and connect to a toio cube
IO.puts("Scanning for toio cubes...")
{:ok, cubes} = Toio.discover(count: 1, duration: 5000)

case cubes do
  [] ->
    IO.puts("No toio cubes found!")

  [cube | _] ->
    IO.puts("Connected to cube!")

    # Turn on green light to indicate start
    Toio.turn_on_light(cube, 0, 255, 0)

    # Move forward for 2 seconds
    IO.puts("Moving forward for 2 seconds...")
    Toio.move_timed(cube, 50, 50, 2000)
    Process.sleep(2500)

    # Turn right for 1 second
    IO.puts("Turning right for 1 second...")
    Toio.move_timed(cube, 50, -50, 1000)
    Process.sleep(1500)

    # Move forward for 1.5 seconds
    IO.puts("Moving forward for 1.5 seconds...")
    Toio.move_timed(cube, 50, 50, 1500)
    Process.sleep(2000)

    # Turn left for 1 second
    IO.puts("Turning left for 1 second...")
    Toio.move_timed(cube, -50, 50, 1000)
    Process.sleep(1500)

    # Move backward for 1 second
    IO.puts("Moving backward for 1 second...")
    Toio.move_timed(cube, -50, -50, 1000)
    Process.sleep(1500)

    # Turn off light
    Toio.turn_off_light(cube)

    IO.puts("Done!")
end
