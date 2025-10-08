defmodule Toio.Specs.ButtonSpecTest do
  use ExUnit.Case, async: true

  alias Toio.Specs.ButtonSpec
  alias Toio.Types.ButtonState

  describe "decode/1" do
    test "decodes button pressed" do
      data = <<0x01, 0x80, 0x00>>
      assert {:ok, %ButtonState{button_id: 1, pressed: true}} = ButtonSpec.decode(data)
    end

    test "decodes button released" do
      data = <<0x01, 0x00, 0x00>>
      assert {:ok, %ButtonState{button_id: 1, pressed: false}} = ButtonSpec.decode(data)
    end

    test "handles different button IDs" do
      data = <<0x02, 0x80, 0x00>>
      assert {:ok, %ButtonState{button_id: 2, pressed: true}} = ButtonSpec.decode(data)
    end

    test "returns error for invalid data" do
      data = <<>>
      assert {:error, :invalid_data} = ButtonSpec.decode(data)
    end
  end
end
