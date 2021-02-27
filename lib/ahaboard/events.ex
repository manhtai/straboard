defmodule Ahaboard.Events do
  @moduledoc """
  Events context
  """

  import Ecto.Query

  alias Ahaboard.Repo
  alias Ahaboard.Events.{Event, Team, EventTeamUser}

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

  def refresh_cache(%Event{id: id} = _event) do
    stats =
      from(etu in EventTeamUser,
        group_by: etu.team_id,
        select: {etu.team_id, count(etu.id)}
      )
      |> Repo.all()

    stats = stats |> Enum.into(%{})

    Team
    |> where(event_id: ^id)
    |> Repo.all()
    |> Enum.each(fn team ->
      team
      |> Team.changeset_cache(%{
        member_count: stats[team.id] || 0,
        activity_count: 0,
        total_distance: 0
      })
      |> Repo.update()
    end)
  end
end
