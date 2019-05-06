defmodule HoplonServer.API.Actions.FetchAudits do
  use Raxx.SimpleServer

  alias HoplonServer.API
  alias HoplonServer.Queries
  alias Hoplon.Crypto

  @impl Raxx.SimpleServer
  def handle_request(
        request = %{
          method: :POST,
          path: ["audits", "fetch", ecosystem, package_name, package_hash]
        },
        _state
      ) do
    with {:ok, body} <- decode_request_body(request.body),
         fingerprints = body["fingerprints"] do
      audits = Queries.get_latest_audits(ecosystem, package_name, package_hash, fingerprints)

      audits_json =
        audits
        |> Enum.map(fn
          %{audit_binary: audit_binary, signature: signature} ->
            %{
              encoded_audit: Crypto.hex_encode!(audit_binary),
              signature: Crypto.hex_encode!(signature)
            }
        end)

      response(:ok)
      |> API.set_json_payload(%{audits: audits_json})
    else
      {:error, message} when is_binary(message) ->
        response(:bad_request)
        |> API.set_json_payload(%{error: message})
    end
  end

  defp decode_request_body(body) do
    case Jason.decode(body) do
      {:ok, %{"fingerprints" => fs} = params} when is_list(fs) ->
        {:ok, params}

      {:ok, _} ->
        message = "invalid request body"
        {:error, message}

      {:error, _} ->
        {:error, "Could not decode request data"}
    end
  end
end
