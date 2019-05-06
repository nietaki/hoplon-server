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

        case insert_key(row) do
          {:error, :already_exists_with_same_fingerprint} ->
            # a key got inserted in the meantime, it's safe to retry,
            # we won't hit the same branch of code
            ensure_public_key(fingerprint, pem)

          {:ok, _key} = success ->
            success
        end

      key = %{pem: ^pem} ->
        {:ok, key}

      other_key ->
        {:error, {:already_exists, other_key}}
    end
  end

  def audit_exists?(audit_binary) when is_binary(audit_binary) do
    query =
      from(a in AuditSchema,
        where: a.audit_binary == ^audit_binary,
        limit: 1
      )

    Repo.exists?(query)
  end

  def get_public_key(fingerprint) do
    Repo.get(PublicKeySchema, fingerprint)
  end

  def insert_key(%PublicKeySchema{} = key) do
    result =
      key
      |> Ecto.Changeset.cast(%{}, [])
      |> Ecto.Changeset.unique_constraint(:public_keys_pkey, name: :public_keys_pkey)
      |> Repo.insert()

    case result do
      {:ok, _key} ->
        result

      {:error, %Ecto.Changeset{errors: [{:public_keys_pkey, _}]}} ->
        {:error, :already_exists_with_same_fingerprint}
    end
  end

  def get_audits(ecosystem, package_name, package_hash, fingerprints)
      when is_list(fingerprints) do
    query =
      from(a in AuditSchema,
        where: a.ecosystem == ^ecosystem,
        where: a.package_name == ^package_name,
        where: a.package_hash == ^package_hash,
        where: a.fingerprint in ^fingerprints
      )

    Repo.all(query)
  end

  def get_latest_audits(ecosystem, package_name, package_hash, fingerprints) do
    get_audits(ecosystem, package_name, package_hash, fingerprints)
    |> Enum.group_by(& &1.fingerprint)
    |> Enum.map(fn
      {_fingerprint, audits} ->
        Enum.max_by(audits, & &1.audit_created_at)
    end)
  end
end
