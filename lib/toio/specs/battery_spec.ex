defmodule Toio.Specs.BatterySpec do
  @moduledoc """
  Decoder for Battery characteristic.
  """

  alias Toio.Types.BatteryInfo

  @doc """
  Decode battery information.
  """
  @spec decode(binary()) :: {:ok, BatteryInfo.t()} | {:error, :invalid_data}
  def decode(<<percentage, _rest::binary>>) do
    {:ok, %BatteryInfo{percentage: percentage}}
  end

  def decode(_), do: {:error, :invalid_data}
end
