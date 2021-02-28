defmodule Straboard.Events do
  @moduledoc """
  Events context
  """

  import Ecto.Query

  alias Straboard.Repo
  alias Straboard.Events.{Event, Team, EventTeamUser}
  alias Straboard.Teams
  alias Straboard.Users.Activity

  @spec joined_events(binary(), map) :: [Event.t()]
  def joined_events(user_id, _params) do
    from(etu in EventTeamUser,
      where: etu.user_id == ^user_id,
      inner_join: event in Event,
      on: event.id == etu.event_id,
      order_by: [desc: event.inserted_at],
      select: event
    )
    |> Repo.all()
  end

  @spec created_events(binary(), map) :: [Event.t()]
  def created_events(user_id, _params) do
    Event
    |> where(user_id: ^user_id)
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  @spec get_event!(binary()) :: Event.t() | nil
  def get_event!(id) do
    Event |> Repo.get!(id)
  end

  @spec get_event!(binary(), integer) :: Event.t() | nil
  def get_event!(id, user_id) do
    Event |> Repo.get_by!(id: id, user_id: user_id)
  end

  @spec get_event_by_code(binary()) :: Event.t() | nil
  def get_event_by_code(code) do
    Event |> Repo.get_by(code: code)
  end

  @spec create_event(map()) :: {:ok, Event.t()} | {:error, Ecto.Changeset.t()}
  def create_event(attrs \\ %{}) do
    %Event{}
    |> Event.changeset(attrs)
    |> Event.clean_code()
    |> Repo.insert()
  end

  @spec update_event(Event.t(), map()) :: {:ok, Event.t()} | {:error, Ecto.Changeset.t()}
  def update_event(%Event{} = event, attrs) do
    event
    |> Event.changeset(attrs)
    |> Repo.update()
  end

  @spec get_event_user(Event.t(), binary()) :: nil | EventTeamUser.t()
  def get_event_user(%Event{id: id} = _event, user_id) do
    case user_id do
      nil ->
        nil

      _ ->
        EventTeamUser
        |> where(event_id: ^id, user_id: ^user_id)
        |> Repo.one()
    end
  end

  @spec join_event(Event.t(), Team.t(), binary()) ::
          {:ok, EventTeamUser.t()} | {:error, Ecto.Changeset.t()}
  def join_event(%Event{id: event_id} = event, %Team{id: team_id} = team, user_id) do
    attrs = %{
      event_id: event_id,
      user_id: user_id,
      team_id: team_id,
      event_role: if(event.user_id == user_id, do: "owner", else: "member"),
      team_role: if(team.user_id == user_id, do: "owner", else: "member")
    }

    case get_event_user(event, user_id) do
      nil ->
        %EventTeamUser{}
        |> EventTeamUser.changeset(attrs)
        |> Repo.insert()

      record ->
        record
        |> EventTeamUser.changeset(attrs)
        |> Repo.update()
    end
  end

  @spec leave_event(Event.t(), binary()) ::
          {:ok, EventTeamUser.t()} | {:error, Ecto.Changeset.t()}
  def leave_event(%Event{} = event, user_id) do
    event
    |> get_event_user(user_id)
    |> Repo.delete()
  end

  def refresh_cache(%Event{id: id} = _event, sync \\ false) do
    case sync do
      false ->
        %{event_id: id}
        |> Straboard.EventRefreshCache.new()
        |> Oban.insert()

      true ->
        calculate_team_stats(id)
    end
  end

  def calculate_team_stats(event_id) do
    get_team_stats(event_id)
    |> cache_team_stats()
  end

  def get_team_stats(event_id) do
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
        average_speed: sum(a.distance) / sum(a.moving_time),
        activity_count: count(a.id),
        member_count: count(etu.user_id, :distinct)
      }
    )
    |> Repo.all()
  end

  def cache_team_stats(stats_list) do
    stats_list
    |> Enum.each(fn attrs ->
      attrs = %{
        id: attrs.id,
        total_distance: attrs.total_distance || 0.0,
        average_speed: attrs.average_speed || 0.0,
        activity_count: attrs.activity_count || 0,
        member_count: attrs.member_count || 0
      }

      team = Teams.get_team!(attrs.id)

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
  end
end
