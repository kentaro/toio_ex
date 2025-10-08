
# Interactive control example
# Control a toio cube using keyboard input

defmodule InteractiveControl do
  def run do
    IO.puts("Scanning for toio cubes...")
    {:ok, cubes} = Toio.discover(count: 1, duration: 5000)

    case cubes do
      [] ->
        IO.puts("No toio cubes found!")

      [cube | _] ->
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

        Toio.turn_on_light(cube, 0, 255, 0)
        control_loop(cube)
    end
  end

  defp control_loop(cube) do
    case IO.gets("") |> String.trim() do
      "w" ->
        IO.puts("→ Moving forward")
        Toio.move(cube, 50, 50)
        control_loop(cube)

      "s" ->
        IO.puts("→ Moving backward")
        Toio.move(cube, -50, -50)
        control_loop(cube)

      "a" ->
        IO.puts("→ Turning left")
        Toio.move(cube, -50, 50)
        control_loop(cube)

      "d" ->
        IO.puts("→ Turning right")
        Toio.move(cube, 50, -50)
        control_loop(cube)

      " " ->
        IO.puts("→ Stop")
        Toio.stop(cube)
        control_loop(cube)

      "1" ->
        IO.puts("→ Red LED")
        Toio.turn_on_light(cube, 255, 0, 0)
        control_loop(cube)

      "2" ->
        IO.puts("→ Green LED")
        Toio.turn_on_light(cube, 0, 255, 0)
        control_loop(cube)

      "3" ->
        IO.puts("→ Blue LED")
        Toio.turn_on_light(cube, 0, 0, 255)
        control_loop(cube)

      "4" ->
        IO.puts("→ Yellow LED")
        Toio.turn_on_light(cube, 255, 255, 0)
        control_loop(cube)

      "5" ->
        IO.puts("→ Cyan LED")
        Toio.turn_on_light(cube, 0, 255, 255)
        control_loop(cube)

      "6" ->
        IO.puts("→ Magenta LED")
        Toio.turn_on_light(cube, 255, 0, 255)
        control_loop(cube)

      "7" ->
        IO.puts("→ White LED")
        Toio.turn_on_light(cube, 255, 255, 255)
        control_loop(cube)

      "p" ->
        IO.puts("→ Playing sound")
        Toio.play_sound_effect(cube, :selected)
        control_loop(cube)

      "q" ->
        IO.puts("→ Quitting...")
        Toio.stop(cube)
        Toio.turn_off_light(cube)
        IO.puts("Goodbye!")

      _ ->
        IO.puts("Invalid command!")
        control_loop(cube)
    end
  end
end

InteractiveControl.run()
