defmodule HoplonServer.RepoCase do
  use ExUnit.CaseTemplate
  # SEE https://hexdocs.pm/ecto/testing-with-ecto.html for more information

  using do
    quote do
      # alias HoplonServer.Repo

      # import Ecto
      # import Ecto.Query
      # import HoplonServer.RepoCase
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(HoplonServer.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(HoplonServer.Repo, {:shared, self()})
    end

    :ok
  end
end
