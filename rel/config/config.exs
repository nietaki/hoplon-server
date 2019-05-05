use Mix.Config

config :hoplon_server,
  example: "example is #{System.get_env("EXAMPLE")}"


config :hoplon_server, HoplonServer.Repo,
  url: System.get_env("DATABASE_URL")
