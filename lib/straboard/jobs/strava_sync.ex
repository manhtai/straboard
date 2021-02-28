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
  def perform(%Oban.Job{args: %{"user_id" => user_id} = _args}, log_error \\ false) do
    user = Users.get_by_id!(user_id)

    client =
      Strava.Client.new(user.token,
        refresh_token: user.refresh_token,
        token_refreshed: fn client ->
          # FIXME: "strava" package failed to parse access_token, so I have to parse it myself
          case client.token do
            %OAuth2.AccessToken{access_token: access_token} ->
              case Jason.decode(access_token) do
                {:ok, token} ->
                  Users.update_token(user, token)
                  Logger.info("Perform sync again for user #{user_id}")
                  perform(%Oban.Job{args: %{"user_id" => user_id}}, true)

                _ ->
                  :ignore
              end

            _ ->
              :ignore
          end
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
        if log_error do
          Logger.error(error)
        end
        result
    end
  end
end
