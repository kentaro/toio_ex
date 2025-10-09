
# Event handling example
# Demonstrates the new pipeable event handling API

# Discover and connect to a toio cube
IO.puts("Scanning for toio cubes...")
{:ok, cubes} = Toio.discover(count: 1, duration: 5000)

case cubes do
  [] ->
    IO.puts("No toio cubes found!")

  [cube | _] ->
    IO.puts("Connected to cube!")
    IO.puts("Press the button, move the cube, or wait for battery updates...")
    IO.puts("(Will listen for 30 seconds)")

    # Attach event handlers using the pipeable API
    cube
    |> Toio.on(:button, fn event ->
      status = if event.pressed, do: "pressed", else: "released"
      IO.puts("🔘 Button #{status}")
    end)
    |> Toio.on(:sensor, fn event ->
      if event.collision do
        IO.puts("💥 Collision detected!")
      end
      if event.double_tap do
        IO.puts("👆 Double tap detected!")
      end
    end)
    |> Toio.on(:battery, fn event ->
      IO.puts("🔋 Battery: #{event.percentage}%")
    end)

    # You can also use filtered handlers
    cube
    |> Toio.on(:button, & &1.pressed, fn _event ->
      IO.puts("✨ Button press only (filtered)")
    end)
    |> Toio.on(:battery, &(&1.percentage < 20), fn event ->
      IO.puts("⚠️  Low battery warning: #{event.percentage}%")
    end)

    # Keep the script running to receive events
    Process.sleep(30_000)

    IO.puts("\nDone! Disconnecting...")
    Toio.disconnect(cube)
end
