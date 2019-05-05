defmodule HoplonServer.API.Actions.UploadAudit do
  use Raxx.SimpleServer
  alias HoplonServer.API
  require Logger

  @impl Raxx.SimpleServer
  def handle_request(request = %{method: :POST}, _state) do
    with {:ok, params} <- decode_request_body(request.body),
         {:ok, audit} <- decode_audit(params["audit_hex"]),
         {:ok, signature_binary} <- Hoplon.Crypto.hex_decode(params["signature_hex"]),
         {:ok, public_key} <- Hoplon.Crypto.decode_public_key_from_pem(params["public_key_pem"]) do
      Logger.info(inspect(audit))
      Logger.info(inspect(public_key))

      response(:ok)
      |> API.set_json_payload(%{data: params})
    else
      {:error, message} when is_binary(message) ->
        response(:bad_request)
        |> API.set_json_payload(%{error: message})

      {:error, error = %Hoplon.Error{}} ->
        response(:bad_request)
        |> API.set_json_payload(Map.from_struct(error))
    end
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
        case Hoplon.Data.Encoder.decode(binary, :audit) do
          {:ok, audit} ->
            {:ok, audit}

          _ ->
            {:error, "could not decode audit from DER"}
        end

      {:error, _} ->
        {:error, "could not decode audit from hex"}
    end
  end
end