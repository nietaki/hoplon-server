defmodule HoplonServer.API do
  def child_spec([config, server_options]) do
    {:ok, port} = Keyword.fetch(server_options, :port)

    %{
      id: {__MODULE__, port},
      start: {__MODULE__, :start_link, [config, server_options]},
      type: :supervisor
    }
  end

  def start_link(config, server_options) do
    stack = HoplonServer.API.Router.stack(config)

    Ace.HTTP.Service.start_link(stack, server_options)
  end

  # Utilities
  def set_json_payload(response, data) do
    response
    |> Raxx.set_header("content-type", "application/json")
    |> Raxx.set_body(Jason.encode!(data))
  end
end
