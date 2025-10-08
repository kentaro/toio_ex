defmodule Toio.Specs.SensorSpec do
  @moduledoc """
  Decoder for Sensor characteristic.
  """

  alias Toio.Types.{AttitudeEuler, AttitudeQuaternion, MagneticSensor, MotionSensor}

  @type decoded ::
          {:ok,
           MotionSensor.t() | MagneticSensor.t() | AttitudeEuler.t() | AttitudeQuaternion.t()}
          | {:error, :invalid_data}

  @doc """
  Decode sensor information data.
  """
  @spec decode(binary()) :: decoded()
  def decode(<<0x01, horizontal, collision, double_tap, posture, shake, _rest::binary>>) do
    {:ok,
     %MotionSensor{
       horizontal: horizontal == 0x01,
       collision: collision == 0x01,
       double_tap: double_tap == 0x01,
       posture: MotionSensor.decode_posture(posture),
       shake: shake
     }}
  end

  def decode(
        <<0x02, state, force_intensity, force_x::signed-8, force_y::signed-8, force_z::signed-8,
          _rest::binary>>
      ) do
    {:ok,
     %MagneticSensor{
       state: decode_magnet_state(state),
       force_intensity: force_intensity,
       force_x: force_x,
       force_y: force_y,
       force_z: force_z
     }}
  end

  def decode(
        <<0x03, 0x01, roll::signed-little-16, pitch::signed-little-16, yaw::signed-little-16,
          _rest::binary>>
      ) do
    {:ok, %AttitudeEuler{roll: roll, pitch: pitch, yaw: yaw}}
  end

  def decode(
        <<0x03, 0x02, w::little-float-32, x::little-float-32, y::little-float-32,
          z::little-float-32, _rest::binary>>
      ) do
    {:ok, %AttitudeQuaternion{w: w, x: x, y: y, z: z}}
  end

  def decode(_), do: {:error, :invalid_data}

  defp decode_magnet_state(0x00), do: :none
  defp decode_magnet_state(state) when state in 0x01..0x06, do: {:magnet, state}
  defp decode_magnet_state(_), do: :unknown
end
