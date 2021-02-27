defmodule Straboard.EventRefreshCache do
  @moduledoc """
  Refresh event leaderboard
  """
  import Ecto.Query

  require Logger

  alias Straboard.Repo
  alias Straboard.Events.{EventTeamUser, Team, Event}
  alias Straboard.Users.Activity
  alias Straboard.Teams

  use Oban.Worker,
    queue: :default,
    priority: 3,
    max_attempts: 1,
    tags: ["cache"],
    unique: [fields: [:args], keys: [:event_id], period: 30]

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"event_id" => event_id} = _args}) do
    from(t in Team,
      left_join: etu in EventTeamUser,
      on: t.id == etu.team_id,
      left_join: e in Event,
      on: t.event_id == e.id,
      left_join: a in Activity,
      on:
        etu.user_id == a.user_id and
          a.start_date_local >= e.start_date and
          a.start_date_local <= e.end_date and
          a.type == e.type,
      where: t.event_id == ^event_id,
      group_by: t.id,
      select: %{
        id: t.id,
        total_distance: sum(a.distance),
        activity_count: count(a.id),
        member_count: count(etu.user_id, :distinct)
      }
    )
    |> Repo.all()
    |> Enum.each(fn attrs ->
      attrs = %{
        id: attrs.id,
        total_distance: attrs.total_distance || 0.0,
        activity_count: attrs.activity_count || 0,
        member_count: attrs.member_count || 0
      }

      team = Teams.get_by_id(attrs.id)

      case attrs.member_count do
        0 ->
          team
          |> Repo.delete!()

        _ ->
          team
          |> Team.changeset_cache(attrs)
          |> Repo.update()
      end
    end)

    :ok
  end
end
