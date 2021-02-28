defmodule Straboard.Users do
  @moduledoc """
  Users context
  """

  alias Straboard.Repo
  alias Straboard.Users.User

  @spec get_by_id!(binary()) :: User.t() | nil
  def get_by_id!(id) do
    User
    |> Repo.get!(id)
  end

  def update_token(user, token) do
    %OAuth2.AccessToken{
      access_token: access_token,
      refresh_token: refresh_token,
      expires_at: expires_at,
      token_type: token_type
    } = token

    user
    |> User.refresh_token_changeset(%{
      token: access_token,
      refresh_token: refresh_token,
      token_expires_at: expires_at,
      token_type: token_type
    })
    |> Repo.update()
  end

  @spec update_or_create(map()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def update_or_create(%{provider: provider, uid: uid} = attrs) do
    user =
      User
      |> Repo.get_by(provider: provider, uid: uid)

    case user do
      nil ->
        %User{}
        |> User.changeset(attrs)
        |> Repo.insert()

      user ->
        user
        |> User.changeset(attrs)
        |> Repo.update()
    end
  end
end
