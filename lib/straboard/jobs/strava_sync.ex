defmodule Straboard.StravaSync do
  @moduledoc """
  Sync data from Strava
  """
  alias Straboard.Users
  alias Straboard.Activities

  require Logger

  use Oban.Worker,
    queue: :default,
    priority: 3,
    max_attempts: 3,
    tags: ["strava"],
    unique: [fields: [:args], keys: [:user_id], period: 30]

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"user_id" => user_id} = _args}) do
    user = Users.get_by_id!(user_id)

    client =
      Strava.Client.new(user.token,
        refresh_token: user.refresh_token,
        token_refreshed: fn client ->
          Users.update_token(user, client.token)
        end
      )

    case Strava.Activities.get_logged_in_athlete_activities(client, per_page: 50, page: 1) do
      {:ok, activities} ->
        activities
        |> Enum.each(fn activity ->
          attrs =
            activity
            |> Map.from_struct()
            |> Map.merge(%{
              user_id: user.id,
              uid: Integer.to_string(activity.id)
            })

          Activities.update_or_create(attrs)
        end)
        Logger.debug("Sync activities success for user #{user_id}")

        :ok

      {:error, error} = result ->
        Logger.error(error)
        result
    end
  end
end
