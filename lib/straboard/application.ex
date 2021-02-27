defmodule Straboard.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Straboard.Repo,
      # Start the Telemetry supervisor
      StraboardWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Straboard.PubSub},
      # Start the Endpoint (http/https)
      StraboardWeb.Endpoint,
      # Start a worker by calling: Straboard.Worker.start_link(arg)
      # {Straboard.Worker, arg}
      {Oban, oban_config()}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Straboard.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp oban_config do
    Application.get_env(:straboard, Oban)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    StraboardWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
