defmodule Toio.Constants do
  @moduledoc """
  BLE UUIDs and constants for toio Core Cube.
  """

  # Service UUID
  @service_uuid "10b20100-5b3b-4571-9508-cf3efcd7bbae"

  # Characteristic UUIDs
  @id_uuid "10b20101-5b3b-4571-9508-cf3efcd7bbae"
  @motor_uuid "10b20102-5b3b-4571-9508-cf3efcd7bbae"
  @light_uuid "10b20103-5b3b-4571-9508-cf3efcd7bbae"
  @sound_uuid "10b20104-5b3b-4571-9508-cf3efcd7bbae"
  @sensor_uuid "10b20106-5b3b-4571-9508-cf3efcd7bbae"
  @button_uuid "10b20107-5b3b-4571-9508-cf3efcd7bbae"
  @battery_uuid "10b20108-5b3b-4571-9508-cf3efcd7bbae"
  @configuration_uuid "10b201ff-5b3b-4571-9508-cf3efcd7bbae"

  @spec service_uuid() :: String.t()
  def service_uuid, do: @service_uuid

  @spec id_uuid() :: String.t()
  def id_uuid, do: @id_uuid

  @spec motor_uuid() :: String.t()
  def motor_uuid, do: @motor_uuid

  @spec light_uuid() :: String.t()
  def light_uuid, do: @light_uuid

  @spec sound_uuid() :: String.t()
  def sound_uuid, do: @sound_uuid

  @spec sensor_uuid() :: String.t()
  def sensor_uuid, do: @sensor_uuid

  @spec button_uuid() :: String.t()
  def button_uuid, do: @button_uuid

  @spec battery_uuid() :: String.t()
  def battery_uuid, do: @battery_uuid

  @spec configuration_uuid() :: String.t()
  def configuration_uuid, do: @configuration_uuid

  # Advertisement name prefix
  @advertisement_prefix "toio-"

  @spec advertisement_prefix() :: String.t()
  def advertisement_prefix, do: @advertisement_prefix
end
