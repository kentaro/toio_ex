# Interactive control example
# Control a toio cube using keyboard input with proper error handling

defmodule InteractiveControl do
  def run do
    IO.puts("Scanning for toio cubes...")

    case Toio.discover(count: 1, duration: 5000) do
      {:ok, []} ->
        IO.puts("No toio cubes found!")
        System.halt(1)

      {:ok, [cube | _]} ->
        IO.puts("Connected to cube!")
        IO.puts("\nControls:")
        IO.puts("  w - Forward")
        IO.puts("  s - Backward")
        IO.puts("  a - Turn left")
        IO.puts("  d - Turn right")
        IO.puts("  space - Stop")
        IO.puts("  1-7 - LED colors")
        IO.puts("  p - Play sound")
        IO.puts("  q - Quit")
        IO.puts("\nReady! Enter command:")

        try do
          :ok = Toio.turn_on_light(cube, 0, 255, 0)
          control_loop(cube)
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
  end

  defp control_loop(cube) do
    case IO.gets("") |> String.trim() do
      "w" ->
        IO.puts("→ Moving forward")
        :ok = Toio.move(cube, 50, 50)
        control_loop(cube)

      "s" ->
        IO.puts("→ Moving backward")
        :ok = Toio.move(cube, -50, -50)
        control_loop(cube)

      "a" ->
        IO.puts("→ Turning left")
        :ok = Toio.move(cube, -50, 50)
        control_loop(cube)

      "d" ->
        IO.puts("→ Turning right")
        :ok = Toio.move(cube, 50, -50)
        control_loop(cube)

      " " ->
        IO.puts("→ Stop")
        :ok = Toio.stop(cube)
        control_loop(cube)

      "1" ->
        IO.puts("→ Red LED")
        :ok = Toio.turn_on_light(cube, 255, 0, 0)
        control_loop(cube)

      "2" ->
        IO.puts("→ Green LED")
        :ok = Toio.turn_on_light(cube, 0, 255, 0)
        control_loop(cube)

      "3" ->
        IO.puts("→ Blue LED")
        :ok = Toio.turn_on_light(cube, 0, 0, 255)
        control_loop(cube)

      "4" ->
        IO.puts("→ Yellow LED")
        :ok = Toio.turn_on_light(cube, 255, 255, 0)
        control_loop(cube)

      "5" ->
        IO.puts("→ Cyan LED")
        :ok = Toio.turn_on_light(cube, 0, 255, 255)
        control_loop(cube)

      "6" ->
        IO.puts("→ Magenta LED")
        :ok = Toio.turn_on_light(cube, 255, 0, 255)
        control_loop(cube)

      "7" ->
        IO.puts("→ White LED")
        :ok = Toio.turn_on_light(cube, 255, 255, 255)
        control_loop(cube)

      "p" ->
        IO.puts("→ Playing sound")
        :ok = Toio.play_sound_effect(cube, :selected)
        control_loop(cube)

      "q" ->
        IO.puts("→ Quitting...")
        :ok = Toio.stop(cube)
        :ok = Toio.turn_off_light(cube)
        IO.puts("Goodbye!")

      _ ->
        IO.puts("Invalid command!")
        control_loop(cube)
    end
  end
end

InteractiveControl.run()
