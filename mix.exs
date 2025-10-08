defmodule Toio.MixProject do
  use Mix.Project

  def project do
    [
      app: :toio,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      # Docs
      name: "Toio",
      source_url: "https://github.com/kentaro/toio",
      homepage_url: "https://github.com/kentaro/toio",
      docs: docs(),
      # Dialyzer
      dialyzer: dialyzer()
    ]
  end

  defp docs do
    [
      main: "Toio",
      extras: ["README.md"],
      groups_for_modules: [
        Core: [Toio, Toio.Scanner, Toio.Cube],
        Supervision: [Toio.CubeSupervisor],
        Specifications: [
          Toio.Specs.IdSpec,
          Toio.Specs.MotorSpec,
          Toio.Specs.LightSpec,
          Toio.Specs.SoundSpec,
          Toio.Specs.SensorSpec,
          Toio.Specs.ButtonSpec,
          Toio.Specs.BatterySpec,
          Toio.Specs.ConfigurationSpec
        ],
        Types: [Toio.Types, Toio.Constants]
      ]
    ]
  end

  defp dialyzer do
    [
      plt_add_apps: [:ex_unit],
      plt_file: {:no_warn, "priv/plts/dialyzer.plt"},
      flags: [:error_handling, :underspecs],
      list_unused_filters: true,
      ignore_warnings: ".dialyzer_ignore.exs"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Toio.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:rustler_btleplug,
       github: "kentaro/rustler_btleplug", branch: "feature/add-write-read-characteristic"},
      {:rustler, ">= 0.0.0", optional: true},
      {:ex_doc, "~> 0.31", only: :dev, runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false}
    ]
  end
end
