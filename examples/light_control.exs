# Light control example
# Demonstrates LED control with proper error handling

# Discover and connect to a toio cube
IO.puts("Scanning for toio cubes...")

case Toio.discover(count: 1, duration: 5000) do
  {:ok, []} ->
    IO.puts("No toio cubes found!")
    System.halt(1)

  {:ok, [cube | _]} ->
    IO.puts("Connected to cube!")

    try do
      # Red light
      IO.puts("Red light...")
      :ok = Toio.turn_on_light(cube, 255, 0, 0)
      Process.sleep(1000)

      # Green light
      IO.puts("Green light...")
      :ok = Toio.turn_on_light(cube, 0, 255, 0)
      Process.sleep(1000)

      # Blue light
      IO.puts("Blue light...")
      :ok = Toio.turn_on_light(cube, 0, 0, 255)
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

      :ok = Toio.play_light_scenario(cube, operations, 3)
      Process.sleep(11000)

      # Turn off
      IO.puts("Turning off light...")
      :ok = Toio.turn_off_light(cube)

      IO.puts("Done!")
    after
      # Always cleanup
      Toio.turn_off_light(cube)
      Toio.disconnect(cube)
    end

  {:error, reason} ->
    IO.puts("Failed to discover cubes: #{inspect(reason)}")
    System.halt(1)
end
