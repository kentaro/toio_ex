# Basic movement example
# Demonstrates how to discover a cube and control its motors with proper error handling

# Discover and connect to a toio cube
IO.puts("Scanning for toio cubes...")

case Toio.discover(count: 1, duration: 5000) do
  {:ok, []} ->
    IO.puts("No toio cubes found!")
    System.halt(1)

  {:ok, [cube | _]} ->
    IO.puts("Connected to cube!")

    try do
      # Move forward
      IO.puts("Moving forward...")
      :ok = Toio.move(cube, 50, 50)
      Process.sleep(2000)

      # Stop
      IO.puts("Stopping...")
      :ok = Toio.stop(cube)
      Process.sleep(1000)

      # Turn right
      IO.puts("Turning right...")
      :ok = Toio.move(cube, 50, -50)
      Process.sleep(1000)

      # Stop
      IO.puts("Stopping...")
      :ok = Toio.stop(cube)
      Process.sleep(1000)

      # Move backward
      IO.puts("Moving backward...")
      :ok = Toio.move(cube, -50, -50)
      Process.sleep(2000)

      # Stop
      IO.puts("Stopping...")
      :ok = Toio.stop(cube)

      IO.puts("Done!")
    after
      # Always cleanup
      Toio.stop(cube)
      Toio.disconnect(cube)
    end

  {:error, reason} ->
    IO.puts("Failed to discover cubes: #{inspect(reason)}")
    System.halt(1)
end
