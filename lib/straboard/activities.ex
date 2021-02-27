defmodule Straboard.Activities do
  @moduledoc """
  Activities context
  """

  alias Straboard.Repo
  alias Straboard.Users.Activity

  @spec update_or_create(map()) :: {:ok, Activity.t()} | {:error, Ecto.Changeset.t()}
  def update_or_create(%{uid: uid, user_id: user_id} = attrs) do
    activity =
      Activity
      |> Repo.get_by(uid: uid, user_id: user_id)

    case activity do
      nil ->
        %Activity{}
        |> Activity.changeset(attrs)
        |> Repo.insert()

      activity ->
        activity
        |> Activity.changeset(attrs)
        |> Repo.update()
    end
  end
end
