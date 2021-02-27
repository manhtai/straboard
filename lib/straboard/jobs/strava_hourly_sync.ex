defmodule Straboard.StravaHourlySync do
  @moduledoc """
  Run Strava sync hourly
  """
  use Oban.Worker

  import Ecto.Query
  alias Straboard.Repo

  alias Straboard.Events.EventTeamUser
  alias Straboard.StravaSync

  @events_limit 1_000

  @impl Oban.Worker
  def perform(_job) do
    # Last 1_000 updated events only
    from(etu in EventTeamUser,
      order_by: [desc: etu.updated_at],
      distinct: etu.user_id,
      limit: @events_limit,
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
