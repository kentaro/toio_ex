# Multiple cubes example
# Demonstrates controlling multiple toio cubes simultaneously with proper error handling

# Discover and connect to multiple toio cubes
IO.puts("Scanning for toio cubes...")

case Toio.discover(count: 2, duration: 5000) do
  {:ok, []} ->
    IO.puts("No toio cubes found!")
    System.halt(1)

  {:ok, [_cube1]} ->
    IO.puts("Found 1 cube. Need at least 2 cubes for this example.")
    System.halt(1)

  {:ok, [cube1, cube2 | _]} ->
    IO.puts("Found 2 cubes! Let's make them dance!")

    try do
      # Turn on different colored lights
      IO.puts("Cube 1: Red light")
      :ok = Toio.turn_on_light(cube1, 255, 0, 0)

      IO.puts("Cube 2: Blue light")
      :ok = Toio.turn_on_light(cube2, 0, 0, 255)

      Process.sleep(2000)

      # Move both cubes forward
      IO.puts("Both cubes moving forward...")
      :ok = Toio.move(cube1, 50, 50)
      :ok = Toio.move(cube2, 50, 50)
      Process.sleep(2000)

      # Stop both
      IO.puts("Stopping...")
      :ok = Toio.stop(cube1)
      :ok = Toio.stop(cube2)
      Process.sleep(1000)

      # Make them turn in opposite directions
      IO.puts("Cube 1: Turning right, Cube 2: Turning left")
      :ok = Toio.move(cube1, 50, -50)
      :ok = Toio.move(cube2, -50, 50)
      Process.sleep(2000)

      # Stop both
      IO.puts("Stopping...")
      :ok = Toio.stop(cube1)
      :ok = Toio.stop(cube2)

      # Play different sounds
      IO.puts("Playing sounds...")
      :ok = Toio.play_sound_effect(cube1, :enter)
      Process.sleep(500)
      :ok = Toio.play_sound_effect(cube2, :mat_in)

      Process.sleep(1000)

      # Turn off lights
      :ok = Toio.turn_off_light(cube1)
      :ok = Toio.turn_off_light(cube2)

      IO.puts("Done!")
    after
      # Always cleanup both cubes
      Toio.stop(cube1)
      Toio.stop(cube2)
      Toio.turn_off_light(cube1)
      Toio.turn_off_light(cube2)
      Toio.disconnect(cube1)
      Toio.disconnect(cube2)
    end

  {:error, reason} ->
    IO.puts("Failed to discover cubes: #{inspect(reason)}")
    System.halt(1)
end
