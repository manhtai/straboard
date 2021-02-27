defmodule Ahaboard.Users do
  @moduledoc """
  Users context
  """

  alias Ahaboard.Repo
  alias Ahaboard.Users.User

  @spec get_or_create(map()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def get_or_create(%{provider: provider, uid: uid} = attrs) do
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
