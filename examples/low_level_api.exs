
# Low-level API example
# Demonstrates using Scanner and CubeSupervisor directly

alias Toio.{Scanner, CubeSupervisor, Cube}

# Scan for cubes manually
IO.puts("Scanning for toio cubes...")
devices = Scanner.scan(duration: 5000, count: 1)

case devices do
  [] ->
    IO.puts("No toio cubes found!")

  [{id, name} | _] ->
    IO.puts("Found cube: #{name} (#{id})")

    # Start a supervised cube process manually
    {:ok, pid} = CubeSupervisor.start_cube({id, name})
    IO.puts("Started cube process: #{inspect(pid)}")

    # Wait for connection
    Process.sleep(15000)

    # Use the cube
    IO.puts("Moving cube...")
    Cube.move(id, 50, 50)
    Process.sleep(2000)

    IO.puts("Stopping cube...")
    Cube.stop(id)
    Process.sleep(1000)

    # Turn on light
    IO.puts("Turning on light...")
    Cube.turn_on_light(id, 255, 0, 255)
    Process.sleep(2000)

    # Play sound
    IO.puts("Playing sound...")
    Cube.play_sound_effect(id, :enter)
    Process.sleep(1000)

    # Disconnect
    IO.puts("Disconnecting...")
    Cube.disconnect(id)

    # Stop the cube process
    IO.puts("Stopping cube process...")
    CubeSupervisor.stop_cube(id)

    IO.puts("Done!")
end
