defmodule Toio.ConstantsTest do
  use ExUnit.Case, async: true

  alias Toio.Constants

  describe "service_uuid/0" do
    test "returns toio service UUID" do
      assert Constants.service_uuid() == "10b20100-5b3b-4571-9508-cf3efcd7bbae"
    end
  end

  describe "characteristic UUIDs" do
    test "id_uuid/0 returns correct UUID" do
      assert Constants.id_uuid() == "10b20101-5b3b-4571-9508-cf3efcd7bbae"
    end

    test "motor_uuid/0 returns correct UUID" do
      assert Constants.motor_uuid() == "10b20102-5b3b-4571-9508-cf3efcd7bbae"
    end

    test "light_uuid/0 returns correct UUID" do
      assert Constants.light_uuid() == "10b20103-5b3b-4571-9508-cf3efcd7bbae"
    end

    test "sound_uuid/0 returns correct UUID" do
      assert Constants.sound_uuid() == "10b20104-5b3b-4571-9508-cf3efcd7bbae"
    end

    test "sensor_uuid/0 returns correct UUID" do
      assert Constants.sensor_uuid() == "10b20106-5b3b-4571-9508-cf3efcd7bbae"
    end

    test "button_uuid/0 returns correct UUID" do
      assert Constants.button_uuid() == "10b20107-5b3b-4571-9508-cf3efcd7bbae"
    end

    test "battery_uuid/0 returns correct UUID" do
      assert Constants.battery_uuid() == "10b20108-5b3b-4571-9508-cf3efcd7bbae"
    end

    test "configuration_uuid/0 returns correct UUID" do
      assert Constants.configuration_uuid() == "10b201ff-5b3b-4571-9508-cf3efcd7bbae"
    end
  end

  describe "advertisement_prefix/0" do
    test "returns toio advertisement prefix" do
      assert Constants.advertisement_prefix() == "toio-"
    end
  end

  describe "UUID format validation" do
    test "all UUIDs follow standard UUID format" do
      uuids = [
        Constants.service_uuid(),
        Constants.id_uuid(),
        Constants.motor_uuid(),
        Constants.light_uuid(),
        Constants.sound_uuid(),
        Constants.sensor_uuid(),
        Constants.button_uuid(),
        Constants.battery_uuid(),
        Constants.configuration_uuid()
      ]

      uuid_regex = ~r/^[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}$/i

      Enum.each(uuids, fn uuid ->
        assert uuid =~ uuid_regex, "UUID #{uuid} does not match standard format"
      end)
    end

    test "all characteristic UUIDs share same base" do
      # UUIDs should end with the base (case insensitive)
      base = "5b3b-4571-9508-cf3efcd7bbae"

      [
        Constants.service_uuid(),
        Constants.id_uuid(),
        Constants.motor_uuid(),
        Constants.light_uuid(),
        Constants.sound_uuid(),
        Constants.sensor_uuid(),
        Constants.button_uuid(),
        Constants.battery_uuid(),
        Constants.configuration_uuid()
      ]
      |> Enum.each(fn uuid ->
        assert String.ends_with?(String.downcase(uuid), base),
               "UUID #{uuid} does not end with base #{base}"
      end)
    end
  end
end
