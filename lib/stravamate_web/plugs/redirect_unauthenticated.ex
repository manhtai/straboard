defmodule StravamateWeb.Plugs.RedirectUnauthenticated do
  import Plug.Conn
  import Phoenix.Controller

  def init(options) do
    options
  end

  def call(conn, _opts) do
    case get_session(conn, "current_user_id") do
      nil ->
        conn = put_session(conn, "next", conn.request_path)
        redirect(conn, to: "/auth/strava") |> halt

      _user ->
        conn
    end
  end
end
