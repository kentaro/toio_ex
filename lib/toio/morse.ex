defmodule Toio.Morse do
  @moduledoc """
  Morse code communication using toio cube's LED and sound.

  This module provides functions to send text as Morse code using
  the cube's LED and sound capabilities.

  ## Default Timing (PARIS standard)

  - Dot duration: 100ms
  - Dash duration: 300ms (3x dot)
  - Symbol gap: 100ms (1x dot)
  - Letter gap: 300ms (3x dot)
  - Word gap: 700ms (7x dot)

  ## Examples

      # Simple SOS signal
      Toio.Morse.send(cube, "SOS")

      # Custom timing and colors
      Toio.Morse.send(cube, "HELLO",
        dot_duration: 150,
        led_color: {255, 0, 0},
        sound_volume: 200
      )

      # Visual only (no sound)
      Toio.Morse.send(cube, "HELLO", sound: false)

      # Sound only (no LED)
      Toio.Morse.send(cube, "HELLO", led: false)
  """

  alias Toio.Cube

  @type morse_options :: [
          {:dot_duration, pos_integer()}
          | {:led_color, {0..255, 0..255, 0..255}}
          | {:sound_volume, 0..255}
          | {:sound, boolean()}
          | {:led, boolean()}
        ]

  # Standard PARIS timing: dot = 100ms
  @default_dot_duration 100
  @default_led_color {255, 255, 0}
  @default_sound_volume 200

  # International Morse Code
  @morse_code %{
    # Letters
    "A" => ".-",
    "B" => "-...",
    "C" => "-.-.",
    "D" => "-..",
    "E" => ".",
    "F" => "..-.",
    "G" => "--.",
    "H" => "....",
    "I" => "..",
    "J" => ".---",
    "K" => "-.-",
    "L" => ".-..",
    "M" => "--",
    "N" => "-.",
    "O" => "---",
    "P" => ".--.",
    "Q" => "--.-",
    "R" => ".-.",
    "S" => "...",
    "T" => "-",
    "U" => "..-",
    "V" => "...-",
    "W" => ".--",
    "X" => "-..-",
    "Y" => "-.--",
    "Z" => "--..",
    # Numbers
    "0" => "-----",
    "1" => ".----",
    "2" => "..---",
    "3" => "...--",
    "4" => "....-",
    "5" => ".....",
    "6" => "-....",
    "7" => "--...",
    "8" => "---..",
    "9" => "----.",
    # Punctuation
    "." => ".-.-.-",
    "," => "--..--",
    "?" => "..--..",
    "'" => ".----.",
    "!" => "-.-.--",
    "/" => "-..-.",
    "(" => "-.--.",
    ")" => "-.--.-",
    "&" => ".-...",
    ":" => "---...",
    ";" => "-.-.-.",
    "=" => "-...-",
    "+" => ".-.-.",
    "-" => "-....-",
    "_" => "..--.-",
    "\"" => ".-..-.",
    "$" => "...-..-",
    "@" => ".--.-.",
    # Space
    " " => " "
  }

  @doc """
  Send text as Morse code using the cube's LED and sound.

  ## Options

    * `:dot_duration` - Duration of a dot in milliseconds (default: 100ms)
    * `:led_color` - RGB tuple for LED color (default: {255, 255, 0} - yellow)
    * `:sound_volume` - Volume for beep sound 0-255 (default: 200)
    * `:sound` - Enable/disable sound (default: true)
    * `:led` - Enable/disable LED (default: true)

  ## Examples

      # Send SOS with defaults
      Toio.Morse.send(cube, "SOS")

      # Send with custom settings
      Toio.Morse.send(cube, "HELLO WORLD",
        dot_duration: 150,
        led_color: {255, 0, 0},
        sound_volume: 255
      )

      # Visual only
      Toio.Morse.send(cube, "OK", sound: false)

      # Audio only
      Toio.Morse.send(cube, "OK", led: false)
  """
  @spec send(Toio.cube(), String.t(), morse_options()) :: :ok
  def send(cube_pid, text, opts \\ []) do
    dot_duration = Keyword.get(opts, :dot_duration, @default_dot_duration)
    led_color = Keyword.get(opts, :led_color, @default_led_color)
    sound_volume = Keyword.get(opts, :sound_volume, @default_sound_volume)
    use_sound = Keyword.get(opts, :sound, true)
    use_led = Keyword.get(opts, :led, true)

    # Validate options
    unless dot_duration > 0 and dot_duration <= 1000 do
      raise ArgumentError, "dot_duration must be between 1 and 1000ms"
    end

    # Convert text to morse code
    morse_pattern = text_to_morse(text)

    # Send morse code
    send_morse_pattern(cube_pid, morse_pattern, %{
      dot_duration: dot_duration,
      dash_duration: dot_duration * 3,
      symbol_gap: dot_duration,
      letter_gap: dot_duration * 3,
      word_gap: dot_duration * 7,
      led_color: led_color,
      sound_volume: sound_volume,
      use_sound: use_sound,
      use_led: use_led
    })

    :ok
  end

  @doc """
  Convert text to Morse code pattern string.

  Converts text to International Morse Code, handling letters (A-Z),
  numbers (0-9), common punctuation, and spaces. Unknown characters
  are silently ignored. Case-insensitive.

  ## Examples

      iex> Toio.Morse.text_to_morse("SOS")
      "... --- ..."

      iex> Toio.Morse.text_to_morse("HELLO")
      ".... . .-.. .-.. ---"

      iex> Toio.Morse.text_to_morse("123")
      ".---- ..--- ...--"

      iex> Toio.Morse.text_to_morse("hello")
      ".... . .-.. .-.. ---"

      iex> Toio.Morse.text_to_morse("HI THERE")
      ".... ..   - .... . .-. ."
  """
  @spec text_to_morse(String.t()) :: String.t()
  def text_to_morse(text) do
    text
    |> String.upcase()
    |> String.graphemes()
    |> Enum.map_join(" ", fn char ->
      Map.get(@morse_code, char, "")
    end)
  end

  @doc """
  Get the Morse code for a single character.

  ## Examples

      iex> Toio.Morse.char_to_morse("A")
      {:ok, ".-"}

      iex> Toio.Morse.char_to_morse("Z")
      {:ok, "--.."}

      iex> Toio.Morse.char_to_morse("!")
      {:ok, "-.-.--"}

      iex> Toio.Morse.char_to_morse("^")
      {:error, :unknown_character}
  """
  @spec char_to_morse(String.t()) :: {:ok, String.t()} | {:error, :unknown_character}
  def char_to_morse(char) when is_binary(char) do
    case Map.get(@morse_code, String.upcase(char)) do
      nil -> {:error, :unknown_character}
      morse -> {:ok, morse}
    end
  end

  # Private functions

  defp send_morse_pattern(cube_pid, pattern, config) do
    pattern
    |> String.graphemes()
    |> Enum.each(fn symbol ->
      case symbol do
        "." -> send_dot(cube_pid, config)
        "-" -> send_dash(cube_pid, config)
        " " -> send_gap(cube_pid, config)
        _ -> :ok
      end
    end)
  end

  defp send_dot(cube_pid, config) do
    signal_on(cube_pid, config.dot_duration, config)
    signal_off(cube_pid, config.symbol_gap, config)
  end

  defp send_dash(cube_pid, config) do
    signal_on(cube_pid, config.dash_duration, config)
    signal_off(cube_pid, config.symbol_gap, config)
  end

  defp send_gap(cube_pid, config) do
    # Space between words (already have symbol_gap, need word_gap - symbol_gap more)
    additional_gap = config.word_gap - config.symbol_gap
    signal_off(cube_pid, additional_gap, config)
  end

  defp signal_on(cube_pid, duration, config) do
    if config.use_led do
      {r, g, b} = config.led_color
      Cube.turn_on_light(cube_pid, r, g, b, duration)
    end

    if config.use_sound do
      # Use a short beep sound effect
      Cube.play_sound_effect(cube_pid, :cursor, config.sound_volume)
    end

    Process.sleep(duration)
  end

  defp signal_off(cube_pid, duration, config) do
    if config.use_led do
      Cube.turn_off_light(cube_pid)
    end

    if config.use_sound do
      Cube.stop_sound(cube_pid)
    end

    Process.sleep(duration)
  end
end
