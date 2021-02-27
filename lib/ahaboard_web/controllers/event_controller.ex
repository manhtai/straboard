defmodule AhaboardWeb.EventController do
  use AhaboardWeb, :controller

  alias Ecto.Changeset
  alias Ahaboard.Users.User
  alias Ahaboard.Events
  alias Ahaboard.Events.Event
  alias AhaboardWeb.ErrorHelpers

  @spec index(Plug.Conn.t(), map) :: Plug.Conn.t()
  def index(conn, params) do
    with %User{id: user_id} <- conn.assigns.current_user do
      events = Events.list_events(user_id, params)
      render(conn, "index.html", events: events)
    end
  end

  @spec create(Plug.Conn.t(), map) :: Plug.Conn.t()
  def create(conn, event_params) do
    with %User{id: user_id} <- conn.assigns.current_user do
      params =
        event_params
        |> Map.merge(%{
          "user_id" => user_id,
        })

      case Events.create_event(params) do
        {:ok, %Event{} = event} ->
          conn
          |> render("show.html", event: event)

        {:error, changeset} ->
          errors = Changeset.traverse_errors(changeset, &ErrorHelpers.translate_error/1)
          conn
          |> render("show.html", event: nil, errors: errors)
      end
    end
  end

  @spec show(Plug.Conn.t(), map) :: Plug.Conn.t()
  def show(conn, %{"id" => id}) do
    event = Events.get_event!(id)
    render(conn, "show.html", event: event)
  end

  @spec update(Plug.Conn.t(), map) :: Plug.Conn.t()
  def update(conn, %{"id" => id, "event" => event_params}) do
    with %User{id: user_id} <- conn.assigns.current_user do
      event = Events.get_event!(id, user_id)

      case Events.update_event(event, event_params) do
        {:ok, %Event{} = event} ->
          conn
          |> render("show.html", event: event)
        {:error, changeset} ->
          errors = Changeset.traverse_errors(changeset, &ErrorHelpers.translate_error/1)
          conn
          |> render("show.html", event: event, errors: errors)
      end
    end
  end
end

