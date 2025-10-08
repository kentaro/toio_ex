defmodule Toio.TypesTest do
  use ExUnit.Case, async: true

  alias Toio.Types.{
    AttitudeEuler,
    AttitudeQuaternion,
    BatteryInfo,
    ButtonState,
    MagneticSensor,
    MotionSensor,
    MotorResponse,
    PositionId,
    StandardId
  }

  describe "PositionId" do
    test "creates struct with all fields" do
      position = %PositionId{
        cube_x: 100,
        cube_y: 200,
        cube_angle: 90,
        sensor_x: 110,
        sensor_y: 210,
        sensor_angle: 95
      }

      assert position.cube_x == 100
      assert position.cube_y == 200
      assert position.cube_angle == 90
      assert position.sensor_x == 110
      assert position.sensor_y == 210
      assert position.sensor_angle == 95
    end
  end

  describe "StandardId" do
    test "creates struct with id and angle" do
      standard = %StandardId{id: 123_456, angle: 180}

      assert standard.id == 123_456
      assert standard.angle == 180
    end
  end

  describe "MotorResponse" do
    test "creates struct with request_id and response_code" do
      response = %MotorResponse{request_id: 42, response_code: :success}

      assert response.request_id == 42
      assert response.response_code == :success
    end

    test "decode_response_code returns correct atoms" do
      assert MotorResponse.decode_response_code(0x00) == :success
      assert MotorResponse.decode_response_code(0x01) == :timeout
      assert MotorResponse.decode_response_code(0x02) == :id_missed
      assert MotorResponse.decode_response_code(0x03) == :invalid_parameter
      assert MotorResponse.decode_response_code(0x04) == :invalid_state
      assert MotorResponse.decode_response_code(0x05) == :overwritten
      assert MotorResponse.decode_response_code(0x06) == :unsupported
    end

    test "decode_response_code returns :unknown for invalid code" do
      assert MotorResponse.decode_response_code(0xFF) == :unknown
    end
  end

  describe "MotionSensor" do
    test "creates struct with all motion data" do
      sensor = %MotionSensor{
        horizontal: true,
        collision: false,
        double_tap: true,
        posture: :top_up,
        shake: 5
      }

      assert sensor.horizontal == true
      assert sensor.collision == false
      assert sensor.double_tap == true
      assert sensor.posture == :top_up
      assert sensor.shake == 5
    end

    test "decode_posture returns correct atoms" do
      assert MotionSensor.decode_posture(0x01) == :top_up
      assert MotionSensor.decode_posture(0x02) == :bottom_up
      assert MotionSensor.decode_posture(0x03) == :back_up
      assert MotionSensor.decode_posture(0x04) == :front_up
      assert MotionSensor.decode_posture(0x05) == :right_up
      assert MotionSensor.decode_posture(0x06) == :left_up
    end

    test "decode_posture returns :unknown for invalid code" do
      assert MotionSensor.decode_posture(0xFF) == :unknown
    end
  end

  describe "MagneticSensor" do
    test "creates struct with magnetic data" do
      sensor = %MagneticSensor{
        state: :none,
        force_intensity: 100,
        force_x: 5,
        force_y: -3,
        force_z: 8
      }

      assert sensor.state == :none
      assert sensor.force_intensity == 100
      assert sensor.force_x == 5
      assert sensor.force_y == -3
      assert sensor.force_z == 8
    end
  end

  describe "AttitudeEuler" do
    test "creates struct with euler angles" do
      euler = %AttitudeEuler{roll: 45, pitch: -30, yaw: 90}

      assert euler.roll == 45
      assert euler.pitch == -30
      assert euler.yaw == 90
    end
  end

  describe "AttitudeQuaternion" do
    test "creates struct with quaternion values" do
      quat = %AttitudeQuaternion{w: 1.0, x: 0.0, y: 0.0, z: 0.0}

      assert quat.w == 1.0
      assert quat.x == 0.0
      assert quat.y == 0.0
      assert quat.z == 0.0
    end
  end

  describe "ButtonState" do
    test "creates struct with button data" do
      button = %ButtonState{button_id: 1, pressed: true}

      assert button.button_id == 1
      assert button.pressed == true
    end
  end

  describe "BatteryInfo" do
    test "creates struct with battery percentage" do
      battery = %BatteryInfo{percentage: 75}

      assert battery.percentage == 75
    end
  end
end
