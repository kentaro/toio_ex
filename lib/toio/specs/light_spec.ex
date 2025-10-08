defmodule Toio.Specs.LightSpec do
  @moduledoc """
  Encoder for Light characteristic.
  """

  @type rgb :: 0..255
  @type duration_ms :: non_neg_integer()
  @type light_operation :: {duration_ms(), rgb(), rgb(), rgb()}

  @doc """
  Turn off all lights.
  """
  @spec encode_turn_off_all() :: <<_::8>>
  def encode_turn_off_all do
    <<0x01>>
  end

  @doc """
  Turn off specific light.
  """
  @spec encode_turn_off(non_neg_integer()) :: binary()
  def encode_turn_off(light_id) do
    <<0x02, light_id>>
  end

  @doc """
  Turn on light with RGB color.
  Duration is in milliseconds (0 for infinite).
  """
  @spec encode_turn_on(rgb(), rgb(), rgb(), duration_ms()) :: binary()
  def encode_turn_on(r, g, b, duration_ms \\ 0) do
    duration = if duration_ms == 0, do: 0, else: min(div(duration_ms, 10), 255)
    <<0x03, duration, 0x01, 0x01, r, g, b>>
  end

  @doc """
  Encode repeating light scenario.
  Operations is a list of {duration_ms, r, g, b} tuples.
  """
  @spec encode_scenario([light_operation()], non_neg_integer()) :: binary()
  def encode_scenario(operations, repeat_count \\ 0) do
    num_operations = min(length(operations), 29)
    ops_binary = encode_operations(Enum.take(operations, num_operations))

    <<0x04, repeat_count, num_operations>> <> ops_binary
  end

  defp encode_operations(operations) do
    Enum.reduce(operations, <<>>, fn {duration_ms, r, g, b}, acc ->
      duration = min(div(duration_ms, 10), 255)
      acc <> <<duration, 0x01, r, g, b, 0x00>>
    end)
  end
end
