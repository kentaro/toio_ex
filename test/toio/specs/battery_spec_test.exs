defmodule Toio.Specs.BatterySpecTest do
  use ExUnit.Case, async: true

  alias Toio.Specs.BatterySpec
  alias Toio.Types.BatteryInfo

  describe "decode/1" do
    test "decodes battery percentage" do
      data = <<100, 0x00>>
      assert {:ok, %BatteryInfo{percentage: 100}} = BatterySpec.decode(data)
    end

    test "decodes various battery levels" do
      assert {:ok, %BatteryInfo{percentage: 0}} = BatterySpec.decode(<<0, 0x00>>)
      assert {:ok, %BatteryInfo{percentage: 50}} = BatterySpec.decode(<<50, 0x00>>)
      assert {:ok, %BatteryInfo{percentage: 10}} = BatterySpec.decode(<<10, 0x00>>)
    end

    test "returns error for empty data" do
      assert {:error, :invalid_data} = BatterySpec.decode(<<>>)
    end
  end
end
