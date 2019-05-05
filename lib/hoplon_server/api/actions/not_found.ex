defmodule HoplonServer.API.Actions.NotFound do
  use Raxx.SimpleServer
  alias HoplonServer.API
  require Logger

  @impl Raxx.SimpleServer
  def handle_request(request, _state) do
    Logger.warn("not found:\n" <> inspect(request))
    error = %{title: "Action not found"}

    response(:not_found)
    |> API.set_json_payload(%{errors: [error]})
  end
end
