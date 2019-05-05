use Mix.Config

config :hoplon_server,
  example: "example is #{System.get_env("EXAMPLE")}",
  app_dir: Application.app_dir("priv/")


config :hoplon_server, HoplonServer.Repo,
  url: System.get_env("DATABASE_URL")
