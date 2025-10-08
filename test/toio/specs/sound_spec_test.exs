defmodule Toio.Specs.SoundSpecTest do
  use ExUnit.Case, async: true

  alias Toio.Specs.SoundSpec

  describe "encode_stop/0" do
    test "encodes stop command" do
      assert SoundSpec.encode_stop() == <<0x01>>
    end
  end

  describe "encode_play_effect/2" do
    test "encodes sound effect with atom" do
      assert SoundSpec.encode_play_effect(:enter, 255) == <<0x02, 0x00, 255>>
    end

    test "encodes various sound effects" do
      assert SoundSpec.encode_play_effect(:selected, 200) == <<0x02, 0x01, 200>>
      assert SoundSpec.encode_play_effect(:cancel, 150) == <<0x02, 0x02, 150>>
      assert SoundSpec.encode_play_effect(:mat_in, 255) == <<0x02, 0x04, 255>>
      assert SoundSpec.encode_play_effect(:mat_out, 255) == <<0x02, 0x05, 255>>
    end

    test "encodes sound effect with integer ID" do
      assert SoundSpec.encode_play_effect(0x03, 100) == <<0x02, 0x03, 100>>
    end

    test "uses default volume" do
      assert SoundSpec.encode_play_effect(:enter) == <<0x02, 0x00, 255>>
    end
  end

  describe "encode_play_midi/2" do
    test "encodes simple MIDI sequence" do
      notes = [{300, 60, 255}, {300, 64, 255}, {300, 67, 255}]
      result = SoundSpec.encode_play_midi(notes, 0)

      <<type, repeat, num_notes, _rest::binary>> = result

      assert type == 0x03
      assert repeat == 0
      assert num_notes == 3
    end

    test "encodes MIDI with repeat count" do
      notes = [{300, 60, 255}]
      result = SoundSpec.encode_play_midi(notes, 3)

      <<_type, repeat, _num_notes, _rest::binary>> = result

      assert repeat == 3
    end

    test "limits notes to 59" do
      notes = for i <- 0..70, do: {100, i, 255}
      result = SoundSpec.encode_play_midi(notes, 0)

      <<_type, _repeat, num_notes, _rest::binary>> = result

      assert num_notes == 59
    end

    test "converts duration to 10ms units" do
      notes = [{250, 60, 200}]
      result = SoundSpec.encode_play_midi(notes, 0)

      <<_type, _repeat, _num_notes, duration, note, volume>> = result

      assert duration == 25
      assert note == 60
      assert volume == 200
    end

    test "handles silence note (128)" do
      notes = [{100, 128, 0}]
      result = SoundSpec.encode_play_midi(notes, 0)

      <<_type, _repeat, _num_notes, _duration, note, _volume>> = result

      assert note == 128
    end
  end

  describe "sound_effect_id/1" do
    test "returns correct ID for effect names" do
      assert SoundSpec.sound_effect_id(:enter) == 0x00
      assert SoundSpec.sound_effect_id(:selected) == 0x01
      assert SoundSpec.sound_effect_id(:cancel) == 0x02
      assert SoundSpec.sound_effect_id(:mat_in) == 0x04
      assert SoundSpec.sound_effect_id(:effect1) == 0x09
    end

    test "returns nil for unknown effect" do
      assert SoundSpec.sound_effect_id(:unknown) == nil
    end
  end
end
