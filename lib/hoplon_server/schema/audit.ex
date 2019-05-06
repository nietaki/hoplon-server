defmodule HoplonServer.Schema.Audit do
  use Ecto.Schema
  require Hoplon.Data
  alias Hoplon.Data

  @primary_key {:id, :binary_id, autogenerate: true}
  @timestamps_opts [type: :utc_datetime_usec]

  schema "audits" do
    # package
    field(:ecosystem, :string)
    field(:package_name, :string)
    field(:package_version, :string)
    field(:package_hash, :string)

    # audit
    field(:verdict, HoplonServer.Ecto.AtomType)
    field(:comment, :string)
    field(:audit_created_at, :integer)
    field(:audited_by_author, :boolean)

    field(:audit_binary, :binary)
    field(:signature, :binary)

    # user
    field(:fingerprint, :string)

    timestamps(updated_at: false)
  end

  def new(audit, audit_binary, signature) when is_tuple(audit) do
    package = Data.audit(audit, :package)

    %__MODULE__{
      ecosystem: Data.package(package, :ecosystem),
      package_name: Data.package(package, :name),
      package_version: Data.package(package, :version),
      package_hash: Data.package(package, :hash),
      verdict: nilify(Data.audit(audit, :verdict)),
      comment: nilify(Data.audit(audit, :comment)),
      audit_created_at: Data.audit(audit, :createdAt),
      audited_by_author: Data.audit(audit, :auditedByAuthor),
      audit_binary: audit_binary,
      signature: signature,
      fingerprint: Data.audit(audit, :publicKeyFingerprint)
    }
  end

  defp nilify(:asn1_NOVALUE), do: nil
  defp nilify(value), do: value
end
