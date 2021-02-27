defmodule StravamateWeb.PageController do
  use StravamateWeb, :controller

  def index(conn, _params) do
    case get_session(conn, :current_user_id) do
      nil -> render(conn, "index.html", current_user_id: nil)
      _ -> redirect(conn, to: "/events")
    end
  end
end
