defmodule HoplonServer.Repo.Migrations.AddAuditIndex do
  use Ecto.Migration

  def change do
    create(index(:audits, [:audit_binary]))
  end
end
