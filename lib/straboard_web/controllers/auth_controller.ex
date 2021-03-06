defmodule StraboardWeb.AuthController do
  use StraboardWeb, :controller

  plug Ueberauth

  alias Ueberauth.Strategy.Helpers
  alias Straboard.UserFromAuth
  alias Straboard.StravaSync

  def request(conn, _params) do
    render(conn, "request.html", callback_url: Helpers.callback_url(conn))
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "You have been logged out!")
    |> clear_session()
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    case UserFromAuth.find_or_create(auth) do
      {:ok, user} ->
        %{user_id: user.id}
        |> StravaSync.new(queue: :default)
        |> Oban.insert()

        conn
        |> put_flash(:info, "Successfully authenticated.")
        |> put_session(:current_user_id, user.id)
        |> configure_session(renew: true)
        |> redirect(to: get_session(conn, "next") || "/events")

      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
        |> redirect(to: "/")
    end
  end
end
