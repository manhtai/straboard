defmodule StravamateWeb.PageController do
  use StravamateWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html", current_user_id: get_session(conn, :current_user_id))
  end
end