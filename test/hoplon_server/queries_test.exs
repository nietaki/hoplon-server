defmodule HoplonServer.QueriesTest do
  use HoplonServer.RepoCase
  alias HoplonServer.Queries

  require Hoplon.Data
  alias Hoplon.Data
  alias HoplonServer.Repo
  alias HoplonServer.Schema.Audit, as: AuditSchema

  @ecosystem "hexpm"
  @name "package_name"
  @version "0.1.0"
  @hash "abcdf"
  @fingerprint "some_fingerprint"
  @created_at 123_456_789_123_456_789
  @verdict :safe

  test "get_latest_audit returns nil for non-existent values" do
    assert nil == Queries.get_latest_audit("foo", "hexpm", "hoplon", "some_hash")
  end

  test "can create an audit entry and fetch it out using get_latest_audit" do
    fake_audit_binary = <<1, 2, 3, 4>>
    fake_signature = <<5, 6, 7, 8>>
    audit_struct = AuditSchema.new(sample_audit(), fake_audit_binary, fake_signature)

    Repo.insert!(audit_struct)

    assert nil == Queries.get_latest_audit("foo", "hexpm", "hoplon", "some_hash")
    assert result = Queries.get_latest_audit(@fingerprint, @ecosystem, @name, @hash)

    assert %AuditSchema{
             id: id,
             ecosystem: @ecosystem,
             package_name: @name,
             package_version: @version,
             package_hash: @hash,
             verdict: @verdict,
             comment: nil,
             audit_created_at: @created_at,
             audited_by_author: false,
             audit_binary: ^fake_audit_binary,
             signature: ^fake_signature,
             fingerprint: @fingerprint
           } = result

    assert is_binary(id)
  end

  test "ensure_public_key guards against fingerprint collisions" do
    assert nil == Queries.get_public_key("foo")

    assert {:ok, key} = Queries.ensure_public_key("foo", "bar")

    assert key == Queries.get_public_key("foo")

    assert {:ok, key} == Queries.ensure_public_key("foo", "bar")

    assert {:error, {:already_exists, key}} == Queries.ensure_public_key("foo", "baz")
  end

  defp sample_package() do
    Data.package(
      ecosystem: @ecosystem,
      name: @name,
      version: @version,
      hash: @hash
    )
  end

  defp sample_audit() do
    Data.audit(
      package: sample_package(),
      verdict: @verdict,
      # comment missing
      publicKeyFingerprint: @fingerprint,
      createdAt: @created_at,
      auditedByAuthor: false
    )
  end
end
