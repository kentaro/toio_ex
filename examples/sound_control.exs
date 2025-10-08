
# Sound control example
# Demonstrates sound effects and MIDI playback

# Discover and connect to a toio cube
IO.puts("Scanning for toio cubes...")
{:ok, cubes} = Toio.discover(count: 1, duration: 5000)

case cubes do
  [] ->
    IO.puts("No toio cubes found!")

  [cube | _] ->
    IO.puts("Connected to cube!")

    # Play sound effects
    IO.puts("Playing sound effect: enter")
    Toio.play_sound_effect(cube, :enter)
    Process.sleep(1000)

    IO.puts("Playing sound effect: selected")
    Toio.play_sound_effect(cube, :selected)
    Process.sleep(1000)

    IO.puts("Playing sound effect: mat_in")
    Toio.play_sound_effect(cube, :mat_in)
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

    Toio.play_midi(cube, notes)
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

    Toio.play_midi(cube, melody)
    Process.sleep(7000)

    IO.puts("Done!")
end
