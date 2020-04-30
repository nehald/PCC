defmodule CCore.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the Ecto repository
      CCore.Repo,
      # Start the endpoint when the application starts
      CCoreWeb.Endpoint,
      # Starts a worker by calling: CCore.Worker.start_link(arg)
      # {CCore.Worker, arg},
      #%{id: GraphDB,
      # start: {CCore.GraphDb, :start_link, [["g"]]}
      CCoreWeb.Presence
      #}

    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CCore.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    CCoreWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
