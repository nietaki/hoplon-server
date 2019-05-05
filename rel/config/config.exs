use Mix.Config

config :hoplon_server,
  example: "example is #{System.get_env("EXAMPLE")}",
  app_dir: Application.app_dir(:hoplon_server, "priv/")

config :hoplon_server, HoplonServer.Repo,
  url: System.get_env("DATABASE_URL"),
  ssl_opts: [
    cacertfile: Application.app_dir(:hoplon_server, "priv/repo/rds-ca-2015-root.pem")
  ]
