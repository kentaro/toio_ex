defmodule Toio.Specs.MotorSpecTest do
  use ExUnit.Case, async: true

  alias Toio.Specs.MotorSpec
  alias Toio.Types.MotorResponse

  describe "encode_move/2" do
    test "encodes forward movement" do
      assert MotorSpec.encode_move(50, 50) == <<0x01, 0x01, 0x01, 50, 0x02, 0x01, 50>>
    end

    test "encodes backward movement" do
      assert MotorSpec.encode_move(-50, -50) == <<0x01, 0x01, 0x02, 50, 0x02, 0x02, 50>>
    end

    test "encodes turning right" do
      assert MotorSpec.encode_move(50, -50) == <<0x01, 0x01, 0x01, 50, 0x02, 0x02, 50>>
    end

    test "encodes turning left" do
      assert MotorSpec.encode_move(-50, 50) == <<0x01, 0x01, 0x02, 50, 0x02, 0x01, 50>>
    end

    test "clamps speed to 115" do
      assert MotorSpec.encode_move(200, 200) == <<0x01, 0x01, 0x01, 115, 0x02, 0x01, 115>>
    end

    test "clamps negative speed to -115" do
      assert MotorSpec.encode_move(-200, -200) == <<0x01, 0x01, 0x02, 115, 0x02, 0x02, 115>>
    end

    test "encodes stop" do
      assert MotorSpec.encode_move(0, 0) == <<0x01, 0x01, 0x01, 0, 0x02, 0x01, 0>>
    end
  end

  describe "encode_move_timed/3" do
    test "encodes timed movement" do
      result = MotorSpec.encode_move_timed(50, 50, 1000)
      assert result == <<0x02, 0x01, 0x01, 50, 0x02, 0x01, 50, 100>>
    end

    test "converts milliseconds to 10ms units" do
      result = MotorSpec.encode_move_timed(30, 30, 2500)
      assert result == <<0x02, 0x01, 0x01, 30, 0x02, 0x01, 30, 250>>
    end

    test "clamps duration to 255 units" do
      result = MotorSpec.encode_move_timed(50, 50, 10_000)
      assert result == <<0x02, 0x01, 0x01, 50, 0x02, 0x01, 50, 255>>
    end
  end

  describe "encode_move_to/4" do
    test "encodes basic move to target" do
      result = MotorSpec.encode_move_to(200, 200, 90, [])

      <<type, _req_id, timeout, movement_type, max_speed, speed_change, 0x00, x::little-16,
        y::little-16, angle::little-16>> = result

      assert type == 0x03
      assert timeout == 5
      assert movement_type == 0
      assert max_speed == 80
      assert speed_change == 0
      assert x == 200
      assert y == 200
      assert angle == 90
    end

    test "encodes with custom options" do
      result = MotorSpec.encode_move_to(100, 100, 45, max_speed: 100, timeout: 10)

      <<_type, _req_id, timeout, _movement_type, max_speed, _speed_change, 0x00, x::little-16,
        y::little-16, angle::little-16>> = result

      assert timeout == 10
      assert max_speed == 100
      assert x == 100
      assert y == 100
      assert angle == 45
    end
  end

  describe "decode/1" do
    test "decodes successful response" do
      data = <<0x83, 42, 0x00, 0x00>>

      assert {:ok, %MotorResponse{request_id: 42, response_code: :success}} =
               MotorSpec.decode(data)
    end

    test "decodes timeout response" do
      data = <<0x83, 10, 0x01, 0x00>>

      assert {:ok, %MotorResponse{request_id: 10, response_code: :timeout}} =
               MotorSpec.decode(data)
    end

    test "decodes id_missed response" do
      data = <<0x83, 5, 0x02, 0x00>>

      assert {:ok, %MotorResponse{request_id: 5, response_code: :id_missed}} =
               MotorSpec.decode(data)
    end

    test "decodes multi-target response" do
      data = <<0x84, 15, 0x00, 0x00>>

      assert {:ok, %MotorResponse{request_id: 15, response_code: :success}} =
               MotorSpec.decode(data)
    end

    test "returns error for invalid data" do
      assert {:error, :invalid_data} = MotorSpec.decode(<<0x99, 0x00>>)
    end
  end
end
