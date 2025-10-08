defmodule Toio.Specs.MotorSpec do
  @moduledoc """
  Encoder/decoder for Motor characteristic.
  """

  alias Toio.Types.MotorResponse

  @type speed :: -115..115
  @type duration_ms :: non_neg_integer()
  @type coordinate :: non_neg_integer()
  @type angle :: 0..360
  @type request_id :: 0..255

  @doc """
  Encode basic motor control command.
  left_speed and right_speed should be -115 to 115 (negative for backward).
  """
  @spec encode_move(speed(), speed()) :: binary()
  def encode_move(left_speed, right_speed) do
    {left_dir, left_abs} = speed_to_dir_and_speed(left_speed)
    {right_dir, right_abs} = speed_to_dir_and_speed(right_speed)

    <<0x01, 0x01, left_dir, left_abs, 0x02, right_dir, right_abs>>
  end

  @doc """
  Encode timed motor control command.
  Duration is in milliseconds, will be converted to 10ms units.
  """
  @spec encode_move_timed(speed(), speed(), duration_ms()) :: binary()
  def encode_move_timed(left_speed, right_speed, duration_ms) do
    {left_dir, left_abs} = speed_to_dir_and_speed(left_speed)
    {right_dir, right_abs} = speed_to_dir_and_speed(right_speed)
    duration = min(div(duration_ms, 10), 255)

    <<0x02, 0x01, left_dir, left_abs, 0x02, right_dir, right_abs, duration>>
  end

  @doc """
  Encode target position motor control command.
  """
  @spec encode_move_to(coordinate(), coordinate(), angle(), keyword()) :: binary()
  def encode_move_to(target_x, target_y, target_angle, opts \\ []) do
    request_id = Keyword.get(opts, :request_id, 0)
    timeout = Keyword.get(opts, :timeout, 5)
    movement_type = Keyword.get(opts, :movement_type, 0)
    max_speed = Keyword.get(opts, :max_speed, 80) |> clamp(10, 255)
    speed_change_type = Keyword.get(opts, :speed_change_type, 0)

    <<0x03, request_id, timeout, movement_type, max_speed, speed_change_type, 0x00,
      target_x::little-16, target_y::little-16, target_angle::little-16>>
  end

  @doc """
  Encode acceleration motor control command.
  """
  def encode_acceleration(
        translation_speed,
        acceleration,
        rotation_speed,
        rotation_dir,
        movement_dir,
        priority,
        control_time_ms
      ) do
    control_time = min(div(control_time_ms, 10), 255)

    <<0x05, translation_speed, acceleration, rotation_speed::little-16, rotation_dir,
      movement_dir, priority, control_time>>
  end

  @doc """
  Decode motor response.
  """
  @spec decode(binary()) :: {:ok, MotorResponse.t()} | {:error, :invalid_data}
  def decode(<<0x83, request_id, response_code, _rest::binary>>) do
    {:ok,
     %MotorResponse{
       request_id: request_id,
       response_code: MotorResponse.decode_response_code(response_code)
     }}
  end

  def decode(<<0x84, request_id, response_code, _rest::binary>>) do
    {:ok,
     %MotorResponse{
       request_id: request_id,
       response_code: MotorResponse.decode_response_code(response_code)
     }}
  end

  def decode(_), do: {:error, :invalid_data}

  # Helper functions

  defp speed_to_dir_and_speed(speed) when speed >= 0 do
    {0x01, clamp(speed, 0, 115)}
  end

  defp speed_to_dir_and_speed(speed) when speed < 0 do
    {0x02, clamp(-speed, 0, 115)}
  end

  defp clamp(value, min_val, max_val) do
    value |> max(min_val) |> min(max_val)
  end
end
