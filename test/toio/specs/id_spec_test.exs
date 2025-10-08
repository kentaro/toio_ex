defmodule Toio.Specs.IdSpecTest do
  use ExUnit.Case, async: true

  alias Toio.Specs.IdSpec
  alias Toio.Types.{PositionId, StandardId}

  describe "decode/1 - Position ID" do
    test "decodes position ID correctly" do
      data =
        <<0x01, 100::little-16, 200::little-16, 45::little-16, 110::little-16, 210::little-16,
          50::little-16, 0x00>>

      assert {:ok,
              %PositionId{
                cube_x: 100,
                cube_y: 200,
                cube_angle: 45,
                sensor_x: 110,
                sensor_y: 210,
                sensor_angle: 50
              }} = IdSpec.decode(data)
    end

    test "handles maximum coordinate values" do
      data =
        <<0x01, 65_535::little-16, 65_535::little-16, 360::little-16, 65_535::little-16,
          65_535::little-16, 360::little-16, 0x00>>

      assert {:ok, %PositionId{cube_x: 65_535, cube_y: 65_535, cube_angle: 360}} =
               IdSpec.decode(data)
    end
  end

  describe "decode/1 - Standard ID" do
    test "decodes standard ID correctly" do
      data = <<0x02, 123_456::little-32, 90::little-16, 0x00>>

      assert {:ok, %StandardId{id: 123_456, angle: 90}} = IdSpec.decode(data)
    end

    test "handles maximum ID value" do
      data = <<0x02, 4_294_967_295::little-32, 360::little-16, 0x00>>

      assert {:ok, %StandardId{id: 4_294_967_295, angle: 360}} = IdSpec.decode(data)
    end
  end

  describe "decode/1 - Missed notifications" do
    test "decodes position ID missed" do
      data = <<0x03, 0x00>>
      assert {:ok, :position_id_missed} = IdSpec.decode(data)
    end

    test "decodes standard ID missed" do
      data = <<0x04, 0x00>>
      assert {:ok, :standard_id_missed} = IdSpec.decode(data)
    end
  end

  describe "decode/1 - Invalid data" do
    test "returns error for unknown type" do
      data = <<0x99, 0x00>>
      assert {:error, :invalid_data} = IdSpec.decode(data)
    end

    test "returns error for malformed data" do
      data = <<0x01, 0x00>>
      assert {:error, :invalid_data} = IdSpec.decode(data)
    end
  end
end
