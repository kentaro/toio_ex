defmodule Toio.Specs.ButtonSpec do
  @moduledoc """
  Decoder for Button characteristic.
  """

  alias Toio.Types.ButtonState

  @doc """
  Decode button state.
  """
  @spec decode(binary()) :: {:ok, ButtonState.t()} | {:error, :invalid_data}
  def decode(<<button_id, state, _rest::binary>>) do
    {:ok, %ButtonState{button_id: button_id, pressed: state == 0x80}}
  end

  def decode(_), do: {:error, :invalid_data}
end
