# Morse Code Communication Example
#
# This example demonstrates sending text as Morse code using
# the toio cube's LED and sound capabilities.
#
# Run with: mix run examples/morse_code.exs

Code.require_file("helpers.exs", __DIR__)

defmodule MorseCodeExample do
  @moduledoc """
  Send messages in Morse code using toio cube.
  """

  def run do
    IO.puts("Morse Code Communication Example")
    IO.puts("=" <> String.duplicate("=", 50))

    # Discover and connect to a cube
    {:ok, cubes} = Toio.discover(count: 1, duration: 3000)

    case cubes do
      [] ->
        IO.puts("No toio cubes found!")

      [cube | _] ->
        IO.puts("Connected to cube!")
        IO.puts("")

        # Example 1: Classic SOS signal
        IO.puts("1. Sending SOS signal...")
        Toio.send_morse(cube, "SOS")
        Process.sleep(2000)

        # Example 2: Hello World with custom color
        IO.puts("2. Sending 'HELLO' with red LED...")
        Toio.send_morse(cube, "HELLO",
          led_color: {255, 0, 0},
          dot_duration: 120
        )
        Process.sleep(2000)

        # Example 3: Numbers
        IO.puts("3. Sending numbers '123'...")
        Toio.send_morse(cube, "123")
        Process.sleep(2000)

        # Example 4: Visual only (silent mode)
        IO.puts("4. Sending 'OK' in silent mode (LED only)...")
        Toio.send_morse(cube, "OK", sound: false)
        Process.sleep(2000)

        # Example 5: Audio only (dark mode)
        IO.puts("5. Sending 'READY' in dark mode (sound only)...")
        Toio.send_morse(cube, "READY", led: false)
        Process.sleep(2000)

        # Example 6: Fast morse (for experts)
        IO.puts("6. Sending 'FAST' at high speed...")
        Toio.send_morse(cube, "FAST",
          dot_duration: 60,
          led_color: {0, 255, 255}
        )
        Process.sleep(2000)

        # Example 7: Slow morse (for learning)
        IO.puts("7. Sending 'SLOW' at slow speed...")
        Toio.send_morse(cube, "SLOW",
          dot_duration: 200,
          led_color: {0, 255, 0}
        )
        Process.sleep(2000)

        # Example 8: Custom message
        IO.puts("8. Sending custom message 'TOIO'...")
        Toio.send_morse(cube, "TOIO",
          led_color: {255, 255, 0},
          sound_volume: 255
        )

        IO.puts("")
        IO.puts("All Morse code examples completed!")
        IO.puts("")
        IO.puts("Morse Code Reference:")
        IO.puts("  A .-    B -...  C -.-.  D -..   E .")
        IO.puts("  F ..-.  G --.   H ....  I ..    J .---")
        IO.puts("  K -.-   L .-..  M --    N -.    O ---")
        IO.puts("  P .--.  Q --.-  R .-.   S ...   T -")
        IO.puts("  U ..-   V ...-  W .--   X -..-  Y -.--")
        IO.puts("  Z --..  1 .---- 2 ..--- 3 ...-- 4 ....-")
        IO.puts("  5 ..... 6 -.... 7 --... 8 ---.. 9 ----.")
        IO.puts("  0 -----")
    end
  end
end

MorseCodeExample.run()
