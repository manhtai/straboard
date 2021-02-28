defmodule StraboardWeb.TeamController do
  use StraboardWeb, :controller

  alias Straboard.Teams
  alias Straboard.Events.Team
  alias Straboard.StringUtil

  @spec show(Plug.Conn.t(), map) :: Plug.Conn.t()
  def show(conn, %{"id" => id}) do
    team = Teams.get_team!(id)
    members = Teams.get_team_members(id)
    current_user_id = get_session(conn, :current_user_id)

    render(
      conn,
      "show.html",
      team: team,
      current_user_id: current_user_id,
      members: members
    )
  end

  @spec edit(Plug.Conn.t(), map) :: Plug.Conn.t()
  def edit(conn, %{"id" => id} = _params) do
    team = Teams.get_team!(id)

    render(
      conn,
      "update.html",
      team: team
    )
  end

  @spec update(Plug.Conn.t(), map) :: Plug.Conn.t()
  def update(conn, %{"id" => id} = team_params) do
    team = Teams.get_team!(id)

    case Teams.update_team(team, team_params) do
      {:ok, %Team{} = team} ->
        conn
        |> put_flash(:info, "Update team success!")
        |> redirect(to: "/events/" <> team.event_id)

      {:error, changeset} ->
        conn
        |> put_flash(:error, StringUtil.changeset_error_to_string(changeset))
        |> redirect(to: "/events/" <> team.event_id)
    end
  end
end
