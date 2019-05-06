defmodule HoplonServer.Schema.PublicKey do
  use Ecto.Schema

  @primary_key {:fingerprint, :string, autogenerate: false}
  @timestamps_opts [type: :utc_datetime_usec]

  schema "public_keys" do
    field(:pem, :string)

    timestamps(updated_at: false)
  end

  def new(fingerprint, pem) when byte_size(fingerprint) <= 64 do
    %__MODULE__{
      fingerprint: fingerprint,
      pem: pem
    }
  end
end
