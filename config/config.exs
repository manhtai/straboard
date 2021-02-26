# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :ahaboard,
  ecto_repos: [Ahaboard.Repo]

# Configures the endpoint
config :ahaboard, AhaboardWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "iAFhezTumNEe855yGemevUOBHhp6sXvNg8PaknHYBJwihzCu1vAy9SlE60LpJEI/",
  render_errors: [view: AhaboardWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Ahaboard.PubSub,
  live_view: [signing_salt: "+Ylg7jPE"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Env
try do
  File.stream!("./.env")
  |> Stream.map(&String.trim_trailing/1)
  |> Enum.each(fn line ->
    line
    |> String.replace("export ", "")
    |> String.split("=", parts: 2)
    |> Enum.reduce(fn value, key ->
      System.put_env(key, value)
    end)
  end)
rescue
  _ -> IO.puts("no .env file found!")
end

# Auth
config :ueberauth, Ueberauth,
  providers: [
    strava: {Ueberauth.Strategy.Strava, [default_scope: "profile:read_all,activity:read"]}
  ]

config :ueberauth, Ueberauth.Strategy.Strava.OAuth,
  client_id: System.get_env("STRAVA_CLIENT_ID"),
  client_secret: System.get_env("STRAVA_CLIENT_SECRET")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
