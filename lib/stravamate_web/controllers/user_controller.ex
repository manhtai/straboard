defmodule StravamateWeb.UserController do
  use StravamateWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
