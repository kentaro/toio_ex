defmodule Toio.Specs.IdSpec do
  @moduledoc """
  Encoder/decoder for ID characteristic.
  """

  alias Toio.Types.{PositionId, StandardId}

  @type decoded ::
          {:ok, PositionId.t() | StandardId.t() | :position_id_missed | :standard_id_missed}
          | {:error, :invalid_data}

  @doc """
  Decode ID information data.
  """
  @spec decode(binary()) :: decoded()
  def decode(
        <<0x01, cube_x::little-16, cube_y::little-16, cube_angle::little-16, sensor_x::little-16,
          sensor_y::little-16, sensor_angle::little-16, _rest::binary>>
      ) do
    {:ok,
     %PositionId{
       cube_x: cube_x,
       cube_y: cube_y,
       cube_angle: cube_angle,
       sensor_x: sensor_x,
       sensor_y: sensor_y,
       sensor_angle: sensor_angle
     }}
  end

  def decode(<<0x02, id::little-32, angle::little-16, _rest::binary>>) do
    {:ok, %StandardId{id: id, angle: angle}}
  end

  def decode(<<0x03, _rest::binary>>), do: {:ok, :position_id_missed}
  def decode(<<0x04, _rest::binary>>), do: {:ok, :standard_id_missed}
  def decode(_), do: {:error, :invalid_data}
end
