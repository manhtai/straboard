defmodule StraboardWeb.EventController do
  use StraboardWeb, :controller

  alias Straboard.Users.User
  alias Straboard.Events
  alias Straboard.Teams
  alias Straboard.Events.Event
  alias Straboard.StringUtil

  @spec index(Plug.Conn.t(), map) :: Plug.Conn.t()
  def index(conn, params) do
    with %User{id: user_id} <- conn.assigns.current_user do
      created_events = Events.created_events(user_id, params)
      joined_events = Events.joined_events(user_id, params)

      render(conn, "index.html", created_events: created_events, joined_events: joined_events)
    end
  end

  @spec create(Plug.Conn.t(), map) :: Plug.Conn.t()
  def create(conn, event_params) do
    with %User{id: user_id} <- conn.assigns.current_user do
      params =
        event_params
        |> Map.merge(%{
          "user_id" => user_id
        })

      case Events.create_event(params) do
        {:ok, %Event{} = event} ->
          conn
          |> put_flash(:info, "Create event success!")
          |> redirect(to: "/events/" <> event.id)

        {:error, changeset} ->
          conn
          |> put_flash(:error, StringUtil.changeset_error_to_string(changeset))
          |> redirect(to: "/events")
      end
    end
  end

  @spec page_create(Plug.Conn.t(), map) :: Plug.Conn.t()
  def page_create(conn, _params) do
    render(conn, "create.html")
  end

  @spec page_update(Plug.Conn.t(), map) :: Plug.Conn.t()
  def page_update(conn, %{"id" => id}) do
    event = Events.get_event!(id)
    render(conn, "update.html", event: event)
  end

  @spec page_join(Plug.Conn.t(), map) :: Plug.Conn.t()
  def page_join(conn, %{"id" => id}) do
    event = Events.get_event!(id)
    render_event_with_teams(conn, event, "join.html")
  end

  @spec show(Plug.Conn.t(), map) :: Plug.Conn.t()
  def show(conn, %{"id" => id}) do
    event = Events.get_event!(id)
    render_event_with_teams(conn, event, "show.html")
  end

  @spec show_by_code(Plug.Conn.t(), map) :: Plug.Conn.t()
  def show_by_code(conn, %{"code" => code}) do
    event = Events.get_event_by_code(code)

    case event do
      nil -> redirect(conn, to: "/")
      _ -> render_event_with_teams(conn, event, "show.html")
    end
  end

  @spec join(Plug.Conn.t(), map) :: Plug.Conn.t()
  def join(conn, %{"id" => id, "team_name" => team_name}) do
    with %User{id: user_id} <- conn.assigns.current_user do
      event = Events.get_event!(id)
      team = Teams.get_or_create_team_by_name!(event, user_id, team_name)

      Events.join_event(event, team, user_id)
      Events.refresh_cache(event, true)
      redirect(conn, to: "/events/" <> event.id)
    end
  end

  @spec leave(Plug.Conn.t(), map) :: Plug.Conn.t()
  def leave(conn, %{"id" => id}) do
    with %User{id: user_id} <- conn.assigns.current_user do
      event = Events.get_event!(id)
      Events.leave_event(event, user_id)
      Events.refresh_cache(event, true)
      redirect(conn, to: "/events/" <> event.id)
    end
  end

  defp render_event_with_teams(conn, event, template) do
    Events.refresh_cache(event, false)

    current_user_id = get_session(conn, :current_user_id)
    teams = Teams.get_teams(event)

    team_name =
      case Events.get_event_user(event, current_user_id) do
        nil ->
          ""

        event_user ->
          team =
            teams
            |> Enum.filter(fn team -> team.id == event_user.team_id end)
            |> Enum.at(0)

          team.name
      end

    render(
      conn,
      template,
      event: event,
      current_user_id: current_user_id,
      team_name: team_name,
      teams: teams
    )
  end

  @spec update(Plug.Conn.t(), map) :: Plug.Conn.t()
  def update(conn, %{"id" => id} = event_params) do
    with %User{id: user_id} <- conn.assigns.current_user do
      event = Events.get_event!(id, user_id)

      case Events.update_event(event, event_params) do
        {:ok, %Event{} = event} ->
          conn
          |> put_flash(:info, "Update event success!")
          |> redirect(to: "/events/" <> event.id)

        {:error, changeset} ->
          conn
          |> put_flash(:error, StringUtil.changeset_error_to_string(changeset))
          |> redirect(to: "/events/" <> event.id)
      end
    end
  end
end
