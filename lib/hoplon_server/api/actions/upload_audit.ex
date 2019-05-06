defmodule HoplonServer.API.Actions.UploadAudit do
  use Raxx.SimpleServer
  alias HoplonServer.API
  require Logger
  alias HoplonServer.Queries
  require Hoplon.Data
  alias Hoplon.Data
  alias HoplonServer.Repo
  alias HoplonServer.Schema.Audit, as: AuditSchema

  @impl Raxx.SimpleServer
  def handle_request(request = %{method: :POST}, _state) do
    with {:ok, params} <- decode_request_body(request.body),
         pem = params["public_key_pem"],
         {:ok, audit_binary, audit} <- decode_audit(params["audit_hex"]),
         {:ok, signature_binary} <- Hoplon.Crypto.hex_decode(params["signature_hex"]),
         {:ok, public_key} <- Hoplon.Crypto.decode_public_key_from_pem(pem),
         key_fingerprint = Hoplon.Crypto.get_fingerprint(public_key),
         audit_fingerprint = Data.audit(audit, :publicKeyFingerprint),
         {:ok, fingerprint} <- validate_fingerprints_match(key_fingerprint, audit_fingerprint),
         {:ok, _key_schema} <- Queries.ensure_public_key(fingerprint, pem) do
      audit_struct = AuditSchema.new(audit, audit_binary, signature_binary)
      Repo.insert!(audit_struct)

      body =
        audit_struct
        |> Map.from_struct()
        |> Map.drop([:__meta__])
        |> Map.drop([:audit_binary, :signature])

      response(:ok)
      |> API.set_json_payload(body)
    else
      {:error, message} when is_binary(message) ->
        response(:bad_request)
        |> API.set_json_payload(%{error: message})

      {:error, {:already_exists, %{pem: pem}}} ->
        response(:bad_request)
        |> API.set_json_payload(%{
          error: "another public key with the same fingerprint was already used",
          pem: pem
        })

      {:error, error = %Hoplon.Error{}} ->
        response(:bad_request)
        |> API.set_json_payload(Map.from_struct(error))
    end
  end

  defp validate_fingerprints_match(fingerprint, fingerprint) do
    {:ok, fingerprint}
  end

  defp validate_fingerprints_match(key_fingerprint, audit_fingerprint) do
    {:error,
     "key fingerprint (#{key_fingerprint}) does not match the audit fingerprint (#{
       audit_fingerprint
     })"}
  end

  defp decode_request_body(body) do
    case Jason.decode(body) do
      {:ok, %{"audit_hex" => _, "signature_hex" => _, "public_key_pem" => _} = params} ->
        {:ok, params}

      {:ok, _} ->
        error = %{title: "Missing required data parameter 'name'"}

        response(:bad_request)
        |> API.set_json_payload(%{errors: [error]})

        message = "missing required param"
        {:error, message}

      {:error, _} ->
        {:error, "Could not decode request data"}
    end
  end

  defp decode_audit(audit_hex) do
    case Hoplon.Crypto.hex_decode(audit_hex) do
      {:ok, binary} ->
        case Hoplon.Data.Encoder.decode(binary, :Audit) do
          {:ok, audit} ->
            {:ok, binary, audit}

          _ ->
            {:error, "could not decode audit from DER"}
        end

      {:error, _} ->
        {:error, "could not decode audit from hex"}
    end
  end
end
