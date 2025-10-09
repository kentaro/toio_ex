# Low-level API example
# Demonstrates using Scanner and CubeSupervisor directly with proper error handling

alias Toio.{Scanner, CubeSupervisor, Cube}

# Scan for cubes manually
IO.puts("Scanning for toio cubes...")
devices = Scanner.scan(duration: 5000, count: 1)

case devices do
  [] ->
    IO.puts("No toio cubes found!")
    System.halt(1)

  [{id, name} | _] ->
    IO.puts("Found cube: #{name} (#{id})")

    # Start a supervised cube process manually
    case CubeSupervisor.start_cube({id, name}) do
      {:ok, pid} ->
        IO.puts("Started cube process: #{inspect(pid)}")

        try do
          # Wait for connection
          Process.sleep(15000)

          # Use the cube
          IO.puts("Moving cube...")
          :ok = Cube.move(id, 50, 50)
          Process.sleep(2000)

          IO.puts("Stopping cube...")
          :ok = Cube.stop(id)
          Process.sleep(1000)

          # Turn on light
          IO.puts("Turning on light...")
          :ok = Cube.turn_on_light(id, 255, 0, 255)
          Process.sleep(2000)

          # Play sound
          IO.puts("Playing sound...")
          :ok = Cube.play_sound_effect(id, :enter)
          Process.sleep(1000)

          IO.puts("Done!")
        after
          # Always cleanup
          IO.puts("Disconnecting...")
          Cube.disconnect(id)

          # Stop the cube process
          IO.puts("Stopping cube process...")
          CubeSupervisor.stop_cube(id)
        end

      {:error, reason} ->
        IO.puts("Failed to start cube process: #{inspect(reason)}")
        System.halt(1)
    end
end
