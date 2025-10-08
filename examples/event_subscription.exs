
# Event subscription example
# Demonstrates how to subscribe to cube events

# Discover and connect to a toio cube
IO.puts("Scanning for toio cubes...")
{:ok, cubes} = Toio.discover(count: 1, duration: 5000)

case cubes do
  [] ->
    IO.puts("No toio cubes found!")

  [cube | _] ->
    IO.puts("Connected to cube!")

    # Subscribe to button events
    Toio.subscribe(cube, :button)
    IO.puts("Subscribed to button events. Press the button on the cube!")

    # Subscribe to sensor events
    Toio.subscribe(cube, :sensor)
    IO.puts("Subscribed to sensor events. Move the cube!")

    # Subscribe to battery events
    Toio.subscribe(cube, :battery)
    IO.puts("Subscribed to battery events.")

    # Listen for events
    listen_for_events(10)

    IO.puts("Done!")
end

defp listen_for_events(0), do: :ok

defp listen_for_events(count) do
  receive do
    {:toio_event, name, :button, button_state} ->
      status = if button_state.pressed, do: "pressed", else: "released"
      IO.puts("[#{name}] Button #{status}")
      listen_for_events(count - 1)

    {:toio_event, name, :sensor, sensor_data} ->
      IO.inspect(sensor_data, label: "[#{name}] Sensor")
      listen_for_events(count - 1)

    {:toio_event, name, :battery, battery_info} ->
      IO.puts("[#{name}] Battery: #{battery_info.percentage}%")
      listen_for_events(count - 1)
  after
    10_000 ->
      IO.puts("Timeout waiting for events")
  end
end
