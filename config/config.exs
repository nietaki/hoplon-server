use Mix.Config

config :hoplon_server,
  ecto_repos: [HoplonServer.Repo]

config :hoplon_server, HoplonServer.Repo,
  # it can be overridden using the DATABASE_URL environment variable
  url: "ecto://YdmO5QsK:HPR8oylnHI1xTYFGc6@localhost:6543/hoplon_server?ssl=false&pool_size=10",
  # https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.SSL.html
  ssl_opts: [
    cacertfile: "priv/repo/rds-ca-2015-root.pem"
  ]

if Mix.env() == :test do
  config :hoplon_server, HoplonServer.Repo, pool: Ecto.Adapters.SQL.Sandbox
end
