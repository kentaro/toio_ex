
# Basic movement example
# Demonstrates how to discover a cube and control its motors

# Discover and connect to a toio cube
IO.puts("Scanning for toio cubes...")
{:ok, cubes} = Toio.discover(count: 1, duration: 5000)

case cubes do
  [] ->
    IO.puts("No toio cubes found!")

  [cube | _] ->
    IO.puts("Connected to cube!")

    # Move forward
    IO.puts("Moving forward...")
    Toio.move(cube, 50, 50)
    Process.sleep(2000)

    # Stop
    IO.puts("Stopping...")
    Toio.stop(cube)
    Process.sleep(1000)

    # Turn right
    IO.puts("Turning right...")
    Toio.move(cube, 50, -50)
    Process.sleep(1000)

    # Stop
    IO.puts("Stopping...")
    Toio.stop(cube)
    Process.sleep(1000)

    # Move backward
    IO.puts("Moving backward...")
    Toio.move(cube, -50, -50)
    Process.sleep(2000)

    # Stop
    IO.puts("Stopping...")
    Toio.stop(cube)

    IO.puts("Done!")
end
