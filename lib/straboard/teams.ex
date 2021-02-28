defmodule Straboard.Teams do
  @moduledoc """
  Events context
  """

  import Ecto.Query

  alias Straboard.Repo
  alias Straboard.Events.{Event, Team, EventTeamUser}
  alias Straboard.Users.User

  @spec get_or_create_team_by_name!(Event.t(), binary(), String.t()) :: Team.t()
  def get_or_create_team_by_name!(%Event{id: id} = _event, user_id, name) do
    team =
      Team
      |> where(event_id: ^id, name: ^name)
      |> Repo.one()

    case team do
      nil ->
        %Team{}
        |> Team.changeset(%{name: name, event_id: id, user_id: user_id})
        |> Repo.insert!()

      _ ->
        team
    end
  end

  @spec get_teams(Event.t()) :: nil | [Team.t()]
  def get_teams(%Event{id: id} = _event) do
    Team
    |> where(event_id: ^id)
    |> order_by(desc: :total_distance)
    |> Repo.all()
  end

  @spec get_team!(binary()) :: nil | Team.t()
  def get_team!(id) do
    Team
    |> Repo.get(id)
  end

  def get_team_members(id) do
    from(etu in EventTeamUser,
      left_join: u in User,
      on: etu.user_id == u.id,
      where: etu.team_id == ^id,
      select: u
    )
    |> Repo.all()
  end
end
