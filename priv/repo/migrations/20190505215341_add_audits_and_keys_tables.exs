defmodule HoplonServer.Repo.Migrations.AddAuditsAndKeysTables do
  use Ecto.Migration

  def change do
    create table(:audits) do
      # package
      add(:ecosystem, :text, null: false)
      add(:package_name, :text, null: false)
      add(:package_version, :text, null: false)
      add(:package_hash, :text, null: false)
      # audit
      # string here because it will always fit in varchar(255)
      add(:verdict, :string, null: true)
      add(:comment, :text, null: true)
      add(:audit_created_at, :bigint, null: false)
      add(:audited_by_author, :boolean, null: false)

      add(:audit_binary, :binary, null: false)
      add(:signature, :binary, null: false)

      # user
      add(:fingerprint, :text, null: false)

      timestamps(updated_at: false)
    end

    # unique index to make sure there's nothing fishy going on with people spamming
    # audits all created at the same time
    create(index(:audits, [:ecosystem, :package_name, :package_hash, :fingerprint, :audit_created_at], unique: true))

    create(index(:audits, [:fingerprint, :ecosystem]))
    create(index(:audits, [:ecosystem, :package_name, :package_version]))

    create table(:public_keys, primary_key: false) do
      add(:fingerprint, :text, null: false, primary_key: true)
      add(:pem, :text, null: false)

      timestamps(updated_at: false)
    end
  end
end
