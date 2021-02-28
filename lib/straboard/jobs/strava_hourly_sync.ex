defmodule Straboard.StravaHourlySync do
  @moduledoc """
  Run Strava sync hourly
  """
  use Oban.Worker

  import Ecto.Query
  alias Straboard.Repo

  alias Straboard.Events.EventTeamUser
  alias Straboard.StravaSync

  # Current Strava ratelimit is 600 / 15 minutes
  @user_limit 500

  @impl Oban.Worker
  def perform(_job) do
    from(etu in EventTeamUser,
      order_by: [desc: etu.updated_at],
      distinct: etu.user_id,
      limit: @user_limit,
      select: etu.user_id
    )
    |> Repo.all()
    |> Enum.each(fn user_id ->
      %{user_id: user_id}
      |> StravaSync.new(queue: :default)
      |> Oban.insert()
    end)

    :ok
  end
end
