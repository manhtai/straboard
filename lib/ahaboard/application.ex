defmodule Ahaboard.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Ahaboard.Repo,
      # Start the Telemetry supervisor
      AhaboardWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Ahaboard.PubSub},
      # Start the Endpoint (http/https)
      AhaboardWeb.Endpoint,
      # Start a worker by calling: Ahaboard.Worker.start_link(arg)
      # {Ahaboard.Worker, arg}
      {Oban, oban_config()}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Ahaboard.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp oban_config do
    Application.get_env(:ahaboard, Oban)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    AhaboardWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
