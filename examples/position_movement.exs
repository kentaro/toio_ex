# Position-based movement example
# Demonstrates moving to specific positions on the toio mat with proper error handling

# NOTE: This example requires a toio play mat with position detection
# The cube must be placed on the mat for this to work

# Discover and connect to a toio cube
IO.puts("Scanning for toio cubes...")

case Toio.discover(count: 1, duration: 5000) do
  {:ok, []} ->
    IO.puts("No toio cubes found!")
    System.halt(1)

  {:ok, [cube | _]} ->
    IO.puts("Connected to cube!")
    IO.puts("Make sure the cube is on a toio play mat!")

    try do
      # Turn on blue light
      :ok = Toio.turn_on_light(cube, 0, 0, 255)

      # Move to position (200, 200) facing 0 degrees
      IO.puts("Moving to position (200, 200, 0°)...")

      :ok =
        Toio.move_to(cube, 200, 200, 0,
          max_speed: 80,
          movement_type: 0,
          speed_change_type: 1
        )

      Process.sleep(3000)

      # Move to position (300, 200) facing 90 degrees
      IO.puts("Moving to position (300, 200, 90°)...")

      :ok =
        Toio.move_to(cube, 300, 200, 90,
          max_speed: 100,
          movement_type: 1
        )

      Process.sleep(3000)

      # Move to position (300, 300) facing 180 degrees
      IO.puts("Moving to position (300, 300, 180°)...")

      :ok =
        Toio.move_to(cube, 300, 300, 180,
          max_speed: 80,
          movement_type: 0,
          speed_change_type: 3
        )

      Process.sleep(3000)

      # Move back to starting position
      IO.puts("Moving back to (200, 200, 0°)...")
      :ok = Toio.move_to(cube, 200, 200, 0)
      Process.sleep(3000)

      # Turn off light
      :ok = Toio.turn_off_light(cube)

      IO.puts("Done!")
    after
      # Always cleanup
      Toio.stop(cube)
      Toio.turn_off_light(cube)
      Toio.disconnect(cube)
    end

  {:error, reason} ->
    IO.puts("Failed to discover cubes: #{inspect(reason)}")
    System.halt(1)
end
