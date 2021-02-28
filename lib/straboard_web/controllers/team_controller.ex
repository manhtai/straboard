defmodule StraboardWeb.TeamController do
  use StraboardWeb, :controller

  alias Straboard.Teams

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
end
