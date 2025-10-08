defmodule Toio.Specs.SoundSpec do
  @moduledoc """
  Encoder for Sound characteristic.
  """

  @type sound_effect ::
          :enter
          | :selected
          | :cancel
          | :cursor
          | :mat_in
          | :mat_out
          | :get1
          | :get2
          | :get3
          | :effect1
          | :effect2
  @type volume :: 0..255
  @type duration_ms :: non_neg_integer()
  @type note_number :: 0..128
  @type midi_note :: {duration_ms(), note_number(), volume()}

  @sound_effects %{
    enter: 0x00,
    selected: 0x01,
    cancel: 0x02,
    cursor: 0x03,
    mat_in: 0x04,
    mat_out: 0x05,
    get1: 0x06,
    get2: 0x07,
    get3: 0x08,
    effect1: 0x09,
    effect2: 0x0A
  }

  @doc """
  Stop playback.
  """
  @spec encode_stop() :: binary()
  def encode_stop do
    <<0x01>>
  end

  @doc """
  Play sound effect.
  """
  @spec encode_play_effect(sound_effect() | non_neg_integer(), volume()) :: binary()
  def encode_play_effect(effect_id, volume \\ 255)

  def encode_play_effect(effect_id, volume) when is_atom(effect_id) do
    effect_code = Map.get(@sound_effects, effect_id, 0x00)
    <<0x02, effect_code, volume>>
  end

  def encode_play_effect(effect_id, volume) when is_integer(effect_id) do
    <<0x02, effect_id, volume>>
  end

  @doc """
  Play MIDI notes.
  Notes is a list of {duration_ms, note_number, volume} tuples.
  Note number 128 is silence. Note 57 = A4 (440 Hz).
  """
  @spec encode_play_midi([midi_note()], non_neg_integer()) :: binary()
  def encode_play_midi(notes, repeat_count \\ 0) do
    num_notes = min(length(notes), 59)
    notes_binary = encode_midi_notes(Enum.take(notes, num_notes))

    <<0x03, repeat_count, num_notes>> <> notes_binary
  end

  defp encode_midi_notes(notes) do
    Enum.reduce(notes, <<>>, fn {duration_ms, note, volume}, acc ->
      duration = clamp(div(duration_ms, 10), 1, 255)
      acc <> <<duration, note, volume>>
    end)
  end

  defp clamp(value, min_val, max_val) do
    value |> max(min_val) |> min(max_val)
  end

  @doc """
  Get sound effect ID by name.
  """
  @spec sound_effect_id(sound_effect()) :: non_neg_integer() | nil
  def sound_effect_id(effect_name), do: Map.get(@sound_effects, effect_name)
end
