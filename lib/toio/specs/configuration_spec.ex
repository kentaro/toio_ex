defmodule Toio.Specs.ConfigurationSpec do
  @moduledoc """
  Encoder/decoder for Configuration characteristic.
  """

  @type angle_degrees :: 1..45
  @type threshold :: 1..10
  @type interval :: 0..255
  @type attitude_format :: 0x01 | 0x02 | 0x03

  @doc """
  Request BLE protocol version.
  """
  @spec encode_request_protocol_version() :: <<_::16>>
  def encode_request_protocol_version do
    <<0x01, 0x00>>
  end

  @doc """
  Set horizontal detection threshold (1-45 degrees).
  """
  @spec encode_horizontal_threshold(angle_degrees()) :: <<_::24>>
  def encode_horizontal_threshold(threshold) when threshold in 1..45 do
    <<0x05, 0x00, threshold>>
  end

  @doc """
  Set collision detection threshold (1-10).
  """
  def encode_collision_threshold(threshold) when threshold in 1..10 do
    <<0x06, 0x00, threshold>>
  end

  @doc """
  Set double tap detection interval (1-7).
  """
  def encode_double_tap_interval(interval) when interval in 1..7 do
    <<0x17, 0x00, interval>>
  end

  @doc """
  Configure ID notification settings.
  """
  def encode_id_notification(min_interval, condition) do
    <<0x18, 0x00, min_interval, condition>>
  end

  @doc """
  Configure ID missed notification sensitivity (0-255 ms).
  """
  def encode_id_missed_notification(sensitivity) do
    <<0x19, 0x00, sensitivity>>
  end

  @doc """
  Configure magnetic sensor.
  function: 0x00=disabled, 0x01=magnet_detect, 0x02=magnetic_force
  interval: 0-255 (0=disabled)
  condition: 0x00=always, 0x01=on_change
  """
  def encode_magnetic_sensor(function, interval, condition) do
    <<0x1B, 0x00, function, interval, condition>>
  end

  @doc """
  Request attitude angle detection.
  format: 0x01=euler, 0x02=quaternion, 0x03=high_precision_euler
  """
  def encode_request_attitude(format) when format in [0x01, 0x02, 0x03] do
    <<0x83, format>>
  end

  @doc """
  Decode configuration response (protocol version).
  """
  @spec decode(binary()) :: {:ok, {:protocol_version, binary()}} | {:error, :invalid_data}
  def decode(<<0x81, 0x00, version::binary-5, _rest::binary>>) do
    {:ok, {:protocol_version, version}}
  end

  def decode(_), do: {:error, :invalid_data}
end
