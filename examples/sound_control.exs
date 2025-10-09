# Sound control example
# Demonstrates sound effects and MIDI playback with proper error handling

# Discover and connect to a toio cube
IO.puts("Scanning for toio cubes...")

case Toio.discover(count: 1, duration: 5000) do
  {:ok, []} ->
    IO.puts("No toio cubes found!")
    System.halt(1)

  {:ok, [cube | _]} ->
    IO.puts("Connected to cube!")

    try do
      # Play sound effects
      IO.puts("Playing sound effect: enter")
      :ok = Toio.play_sound_effect(cube, :enter)
      Process.sleep(1000)

      IO.puts("Playing sound effect: selected")
      :ok = Toio.play_sound_effect(cube, :selected)
      Process.sleep(1000)

      IO.puts("Playing sound effect: mat_in")
      :ok = Toio.play_sound_effect(cube, :mat_in)
      Process.sleep(1000)

      # Play MIDI melody (C major scale)
      IO.puts("Playing C major scale...")

      notes = [
        {300, 60, 255},
        # C4
        {300, 62, 255},
        # D4
        {300, 64, 255},
        # E4
        {300, 65, 255},
        # F4
        {300, 67, 255},
        # G4
        {300, 69, 255},
        # A4
        {300, 71, 255},
        # B4
        {300, 72, 255}
        # C5
      ]

      :ok = Toio.play_midi(cube, notes)
      Process.sleep(3000)

      # Play simple melody (Twinkle Twinkle Little Star)
      IO.puts("Playing Twinkle Twinkle Little Star...")

      melody = [
        {400, 60, 255},
        {400, 60, 255},
        {400, 67, 255},
        {400, 67, 255},
        {400, 69, 255},
        {400, 69, 255},
        {800, 67, 255},
        {400, 65, 255},
        {400, 65, 255},
        {400, 64, 255},
        {400, 64, 255},
        {400, 62, 255},
        {400, 62, 255},
        {800, 60, 255}
      ]

      :ok = Toio.play_midi(cube, melody)
      Process.sleep(7000)

      IO.puts("Done!")
    after
      # Always cleanup
      Toio.stop_sound(cube)
      Toio.disconnect(cube)
    end

  {:error, reason} ->
    IO.puts("Failed to discover cubes: #{inspect(reason)}")
    System.halt(1)
end
