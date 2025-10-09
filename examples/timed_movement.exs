# Timed movement example
# Demonstrates time-based motor control with proper error handling

# Discover and connect to a toio cube
IO.puts("Scanning for toio cubes...")

case Toio.discover(count: 1, duration: 5000) do
  {:ok, []} ->
    IO.puts("No toio cubes found!")
    System.halt(1)

  {:ok, [cube | _]} ->
    IO.puts("Connected to cube!")

    try do
      # Turn on green light to indicate start
      :ok = Toio.turn_on_light(cube, 0, 255, 0)

      # Move forward for 2 seconds
      IO.puts("Moving forward for 2 seconds...")
      :ok = Toio.move_timed(cube, 50, 50, 2000)
      Process.sleep(2500)

      # Turn right for 1 second
      IO.puts("Turning right for 1 second...")
      :ok = Toio.move_timed(cube, 50, -50, 1000)
      Process.sleep(1500)

      # Move forward for 1.5 seconds
      IO.puts("Moving forward for 1.5 seconds...")
      :ok = Toio.move_timed(cube, 50, 50, 1500)
      Process.sleep(2000)

      # Turn left for 1 second
      IO.puts("Turning left for 1 second...")
      :ok = Toio.move_timed(cube, -50, 50, 1000)
      Process.sleep(1500)

      # Move backward for 1 second
      IO.puts("Moving backward for 1 second...")
      :ok = Toio.move_timed(cube, -50, -50, 1000)
      Process.sleep(1500)

      IO.puts("Done!")
    after
      # Always cleanup, even if something fails
      Toio.turn_off_light(cube)
      Toio.disconnect(cube)
    end

  {:error, reason} ->
    IO.puts("Failed to discover cubes: #{inspect(reason)}")
    System.halt(1)
end
