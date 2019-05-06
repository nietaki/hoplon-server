defmodule HoplonServer.Queries do
  alias HoplonServer.Repo
  alias HoplonServer.Schema.Audit, as: AuditSchema
  alias HoplonServer.Schema.PublicKey, as: PublicKeySchema

  import Ecto.Query, only: [from: 2]

  def get_latest_audit(fingerprint, ecosystem, package_name, package_hash) do
    query =
      from(a in AuditSchema,
        where: a.fingerprint == ^fingerprint,
        where: a.ecosystem == ^ecosystem,
        where: a.package_name == ^package_name,
        where: a.package_hash == ^package_hash,
        order_by: [desc: a.audit_created_at],
        limit: 1
      )

    Repo.one(query)
  end

  def ensure_public_key(fingerprint, pem) do
    case get_public_key(fingerprint) do
      nil ->
        # insert
        row = PublicKeySchema.new(fingerprint, pem)
        Repo.insert(row)

      key = %{pem: ^pem} ->
        {:ok, key}

      other_key ->
        {:error, {:already_exists, other_key}}
    end
  end

  def get_public_key(fingerprint) do
    Repo.get(PublicKeySchema, fingerprint)
  end
end
