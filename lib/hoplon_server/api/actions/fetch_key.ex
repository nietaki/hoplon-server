defmodule HoplonServer.API.Actions.FetchKey do
  use Raxx.SimpleServer

  alias HoplonServer.API
  alias HoplonServer.Queries
  alias HoplonServer.Schema.PublicKey, as: PublicKeySchema

  @impl Raxx.SimpleServer
  def handle_request(
        %{
          path: ["keys", "fetch", fingerprint]
        },
        _state
      ) do
    case Queries.get_public_key(fingerprint) do
      nil ->
        response(:not_found)
        |> API.set_json_payload(%{error: "not found"})

      %PublicKeySchema{fingerprint: ^fingerprint, pem: pem} ->
        body = %{
          fingerprint: fingerprint,
          pem: pem
        }

        response(:ok)
        |> API.set_json_payload(body)
    end
  end
end
