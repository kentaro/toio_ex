# Exclude BLE tests on CI or when BLE is not available
exclude =
  if System.get_env("CI") do
    [:integration, :ble]
  else
    [:integration]
  end

ExUnit.start(exclude: exclude)
