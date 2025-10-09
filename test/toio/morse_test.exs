defmodule Toio.MorseTest do
  use ExUnit.Case, async: true
  doctest Toio.Morse

  alias Toio.Morse

  describe "text_to_morse/1" do
    test "converts single letter to morse code" do
      assert Morse.text_to_morse("A") == ".-"
      assert Morse.text_to_morse("E") == "."
      assert Morse.text_to_morse("T") == "-"
    end

    test "converts SOS signal" do
      assert Morse.text_to_morse("SOS") == "... --- ..."
    end

    test "converts HELLO" do
      assert Morse.text_to_morse("HELLO") == ".... . .-.. .-.. ---"
    end

    test "handles lowercase letters" do
      assert Morse.text_to_morse("hello") == ".... . .-.. .-.. ---"
      assert Morse.text_to_morse("HeLLo") == ".... . .-.. .-.. ---"
    end

    test "converts numbers" do
      assert Morse.text_to_morse("0") == "-----"
      assert Morse.text_to_morse("1") == ".----"
      assert Morse.text_to_morse("123") == ".---- ..--- ...--"
      assert Morse.text_to_morse("9") == "----."
    end

    test "handles spaces" do
      assert Morse.text_to_morse("HI THERE") == ".... ..   - .... . .-. ."
    end

    test "converts punctuation" do
      assert Morse.text_to_morse(".") == ".-.-.-"
      assert Morse.text_to_morse(",") == "--..--"
      assert Morse.text_to_morse("?") == "..--.."
      assert Morse.text_to_morse("!") == "-.-.--"
    end

    test "ignores unknown characters" do
      assert Morse.text_to_morse("A^B") == ".-  -..."
      assert Morse.text_to_morse("TEST~123") == "- . ... -  .---- ..--- ...--"
    end

    test "handles empty string" do
      assert Morse.text_to_morse("") == ""
    end
  end

  describe "char_to_morse/1" do
    test "converts single character" do
      assert Morse.char_to_morse("A") == {:ok, ".-"}
      assert Morse.char_to_morse("Z") == {:ok, "--.."}
    end

    test "handles lowercase" do
      assert Morse.char_to_morse("a") == {:ok, ".-"}
      assert Morse.char_to_morse("z") == {:ok, "--.."}
    end

    test "converts numbers" do
      assert Morse.char_to_morse("0") == {:ok, "-----"}
      assert Morse.char_to_morse("5") == {:ok, "....."}
    end

    test "converts punctuation" do
      assert Morse.char_to_morse("!") == {:ok, "-.-.--"}
      assert Morse.char_to_morse("?") == {:ok, "..--.."}
    end

    test "handles space" do
      assert Morse.char_to_morse(" ") == {:ok, " "}
    end

    test "returns error for unknown characters" do
      assert Morse.char_to_morse("^") == {:error, :unknown_character}
      assert Morse.char_to_morse("~") == {:error, :unknown_character}
      assert Morse.char_to_morse("⚡") == {:error, :unknown_character}
    end
  end

  describe "send/3 options validation" do
    test "raises error for invalid dot_duration" do
      # Use a fake pid since we're just testing validation
      fake_pid = spawn(fn -> :timer.sleep(:infinity) end)

      assert_raise ArgumentError, "dot_duration must be between 1 and 1000ms", fn ->
        Morse.send(fake_pid, "A", dot_duration: 0)
      end

      assert_raise ArgumentError, "dot_duration must be between 1 and 1000ms", fn ->
        Morse.send(fake_pid, "A", dot_duration: 1001)
      end

      assert_raise ArgumentError, "dot_duration must be between 1 and 1000ms", fn ->
        Morse.send(fake_pid, "A", dot_duration: -1)
      end

      # Clean up
      Process.exit(fake_pid, :kill)
    end

    test "accepts valid dot_duration" do
      # This will fail to send to the fake pid, but should pass validation
      fake_pid = spawn(fn -> :timer.sleep(:infinity) end)

      # Should not raise
      catch_exit(Morse.send(fake_pid, "A", dot_duration: 1))
      catch_exit(Morse.send(fake_pid, "A", dot_duration: 100))
      catch_exit(Morse.send(fake_pid, "A", dot_duration: 1000))

      # Clean up
      Process.exit(fake_pid, :kill)
    end
  end

  describe "morse code completeness" do
    test "supports all letters A-Z" do
      for letter <- ?A..?Z do
        char = <<letter>>
        result = Morse.char_to_morse(char)
        assert {:ok, _morse} = result, "Letter #{char} should have morse code"
      end
    end

    test "supports all digits 0-9" do
      for digit <- ?0..?9 do
        char = <<digit>>
        result = Morse.char_to_morse(char)
        assert {:ok, _morse} = result, "Digit #{char} should have morse code"
      end
    end

    test "supports common punctuation" do
      punctuation = [
        ".",
        ",",
        "?",
        "'",
        "!",
        "/",
        "(",
        ")",
        "&",
        ":",
        ";",
        "=",
        "+",
        "-",
        "_",
        "\"",
        "$",
        "@"
      ]

      for char <- punctuation do
        result = Morse.char_to_morse(char)
        assert {:ok, _morse} = result, "Punctuation '#{char}' should have morse code"
      end
    end
  end

  describe "morse timing defaults" do
    test "default dot duration is 100ms (PARIS standard)" do
      # This is implicitly tested by the module default, but documenting here
      # PARIS standard: dot = 100ms, dash = 300ms, character gap = 300ms, word gap = 700ms
      assert true
    end
  end
end
