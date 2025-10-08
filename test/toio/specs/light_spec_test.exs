defmodule Toio.Specs.LightSpecTest do
  use ExUnit.Case, async: true

  alias Toio.Specs.LightSpec

  describe "encode_turn_off_all/0" do
    test "encodes turn off all command" do
      assert LightSpec.encode_turn_off_all() == <<0x01>>
    end
  end

  describe "encode_turn_off/1" do
    test "encodes turn off specific light" do
      assert LightSpec.encode_turn_off(1) == <<0x02, 0x01>>
    end
  end

  describe "encode_turn_on/4" do
    test "encodes turn on with infinite duration" do
      assert LightSpec.encode_turn_on(255, 0, 0, 0) == <<0x03, 0, 0x01, 0x01, 255, 0, 0>>
    end

    test "encodes turn on with specific duration" do
      result = LightSpec.encode_turn_on(0, 255, 0, 2000)
      assert result == <<0x03, 200, 0x01, 0x01, 0, 255, 0>>
    end

    test "converts duration to 10ms units" do
      result = LightSpec.encode_turn_on(0, 0, 255, 1500)
      assert result == <<0x03, 150, 0x01, 0x01, 0, 0, 255>>
    end

    test "clamps duration to 255 units" do
      result = LightSpec.encode_turn_on(128, 128, 128, 10_000)
      assert result == <<0x03, 255, 0x01, 0x01, 128, 128, 128>>
    end
  end

  describe "encode_scenario/2" do
    test "encodes simple scenario" do
      operations = [{1000, 255, 0, 0}, {1000, 0, 255, 0}, {1000, 0, 0, 255}]
      result = LightSpec.encode_scenario(operations, 0)

      <<type, repeat, num_ops, _rest::binary>> = result

      assert type == 0x04
      assert repeat == 0
      assert num_ops == 3
    end

    test "encodes scenario with repeat count" do
      operations = [{500, 255, 0, 0}, {500, 0, 255, 0}]
      result = LightSpec.encode_scenario(operations, 5)

      <<_type, repeat, num_ops, _rest::binary>> = result

      assert repeat == 5
      assert num_ops == 2
    end

    test "limits operations to 29" do
      operations = for _i <- 1..50, do: {100, 255, 255, 255}
      result = LightSpec.encode_scenario(operations, 0)

      <<_type, _repeat, num_ops, _rest::binary>> = result

      assert num_ops == 29
    end
  end
end
