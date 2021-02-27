defmodule Ueberauth.Strategy.Strava.OAuth do
  @moduledoc """
  OAuth2 for Strava.
  """

  use OAuth2.Strategy

  @defaults [
    strategy: __MODULE__,
    site: "https://www.strava.com/",
    authorize_url: "https://www.strava.com/oauth/authorize",
    token_url: "https://www.strava.com/oauth/token"
  ]

  def client(opts \\ []) do
    config = Application.get_env(:ueberauth, Ueberauth.Strategy.Strava.OAuth)

    opts =
      @defaults
      |> Keyword.merge(config)
      |> Keyword.merge(opts)

    OAuth2.Client.new(opts)
    |> OAuth2.Client.put_serializer("application/json", Ueberauth.json_library())
  end

  def authorize_url!(params \\ [], opts \\ []) do
    opts
    |> client
    |> OAuth2.Client.authorize_url!(params)
  end

  def get(token, url, headers \\ [], opts \\ []) do
    client(token: token)
    |> put_param("client_secret", client().client_secret)
    |> OAuth2.Client.get(url, headers, opts)
  end

  def get_token!(params \\ [], opts \\ []) do
    opts
    |> client
    |> OAuth2.Client.get_token!(token_params(params))
  end

  def token_params(params \\ []) do
    Application.get_env(:ueberauth, Ueberauth.Strategy.Strava.OAuth)
    |> Keyword.take([:client_id, :client_secret])
    |> Keyword.merge(params)
  end

  def authorize_url(client, params) do
    OAuth2.Strategy.AuthCode.authorize_url(client, params)
  end

  def get_token(client, params, headers) do
    client
    |> put_param(:client_secret, client.client_secret)
    |> put_header("Accept", "application/json")
    |> OAuth2.Strategy.AuthCode.get_token(params, headers)
  end
end
