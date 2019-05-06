defmodule HoplonServer.API.Router do
  use Raxx.Router
  alias HoplonServer.API.Actions

  def stack(config) do
    Raxx.Stack.new(
      [
        # Add global middleware here.
        {Raxx.Logger, Raxx.Logger.setup(level: :info)}
      ],
      {__MODULE__, config}
    )
  end

  # api section
  section([], [
    {%{path: ["audits", "upload"], method: :POST}, Actions.UploadAudit},
    {%{path: ["audits", "fetch", _ecosystem, _package_name, _package_hash], method: :POST},
     Actions.FetchAudits}
  ])

  # Call GreetUser and in WWW dir AND call into lib
  section([], [
    {%{path: []}, Actions.WelcomeMessage}
  ])

  section([], [
    {_, Actions.NotFound}
  ])
end
