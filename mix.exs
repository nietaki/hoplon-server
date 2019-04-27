defmodule HoplonServer.Mixfile do
  use Mix.Project

  def project do
    [
      app: :hoplon_server,
      version: "0.1.0",
      elixir: "~> 1.7.4",
      elixirc_paths: elixirc_paths(Mix.env()),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  def application do
    [extra_applications: [:logger], mod: {HoplonServer.Application, []}]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:ace, "~> 0.18.6"},
      {:raxx_logger, "~> 0.2.2"},
      {:jason, "~> 1.0"},
      {:postgrex, ">= 0.0.0"},
      {:ecto_sql, "~> 3.0.0"}
    ]
  end

  defp aliases() do
    [
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
