defmodule Ahaboard.Events do
  @moduledoc """
  Events context
  """

  import Ecto.Query

  alias Ahaboard.Repo
  alias Ahaboard.Events.{Event, Team, EventTeamUser}

  @spec list_events(binary(), map) :: [Event.t()]
  def list_events(user_id, params) do
    Event
    |> where(user_id: ^user_id)
    |> where(^filter_where(params))
    |> order_by(desc: :updated_at)
    |> limit(100)
    |> Repo.all()
  end

  @spec filter_where(map) :: Ecto.Query.DynamicExpr.t()
  def filter_where(params) do
    Enum.reduce(params, dynamic(true), fn
      {"q", value}, dynamic ->
        dynamic([p], ^dynamic and ilike(p.name, ^"%#{value}%"))

      {_, _}, dynamic ->
        # Not a where parameter
        dynamic
    end)
  end

  @spec get_event!(binary()) :: Event.t() | nil
  def get_event!(id) do
    Event |> Repo.get!(id)
  end

  @spec get_event!(binary(), integer) :: Event.t() | nil
  def get_event!(id, user_id) do
    Event |> Repo.get_by!([id: id, user_id: user_id])
  end

  @spec get_event_by_code(binary()) :: Event.t() | nil
  def get_event_by_code(code) do
    Event |> Repo.get_by([code: code])
  end

  @spec create_event(map()) :: {:ok, Event.t()} | {:error, Ecto.Changeset.t()}
  def create_event(attrs \\ %{}) do
    %Event{}
    |> Event.changeset(attrs)
    |> Event.clean_code()
    |> Repo.insert()
  end

  @spec update_event(Event.t, map()) :: {:ok, Event.t()} | {:error, Ecto.Changeset.t()}
  def update_event(%Event{} = event, attrs) do
    event
    |> Event.changeset(attrs)
    |> Repo.update()
  end

  @spec get_event_user(Event.t(), binary()) :: nil | EventTeamUser.t()
  def get_event_user(%Event{id: id} = _event, user_id) do
    EventTeamUser
    |> where(event_id: ^id, user_id: ^user_id)
    |> Repo.one()
  end

  @spec get_teams(Event.t()) :: nil | [Team.t()]
  def get_teams(%Event{id: id} = _event) do
    Team
    |> where(event_id: ^id)
    |> Repo.all()
  end

  @spec get_or_create_team_by_name!(Event.t(), binary(), String.t()) :: Team.t()
  def get_or_create_team_by_name!(%Event{id: id} = _event, user_id, name) do
    team = Team
           |> where(event_id: ^id, name: ^name)
           |> Repo.one()

    case team do
      nil ->
        %Team{}
        |> Team.changeset(%{name: name, event_id: id, user_id: user_id})
        |> Repo.insert!()

      _ -> team
    end
  end

  @spec join_event(Event.t(), Team.t(), binary()) :: {:ok, EventTeamUser.t()} | {:error, Ecto.Changeset.t()}
  def join_event(%Event{id: event_id} = event, %Team{id: team_id} = team, user_id) do
    case get_event_user(event, user_id) do
      nil ->
        %EventTeamUser{}
        |> EventTeamUser.changeset(%{
          event_id: event_id,
          user_id: user_id,
          team_id: team_id,
          event_role: (if event.user_id == user_id, do: "owner", else: "member"),
          team_role: (if team.user_id == user_id, do: "owner", else: "member"),
        })
        |> Repo.insert()

      record ->
        {:ok, record}
    end
  end

  @spec leave_event(Event.t(), binary()) :: {:ok, EventTeamUser.t()} | {:error, Ecto.Changeset.t()}
  def leave_event(%Event{} = event, user_id) do
    event
    |> get_event_user(user_id)
    |> Repo.delete()
  end
end
