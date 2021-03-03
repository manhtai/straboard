defmodule StraboardWeb.EventLive do
  use StraboardWeb, :live_view

  require Logger

  alias Straboard.Events
  alias Straboard.Teams

  @impl true
  def mount(_params, %{"current_user_id" => current_user_id, "id" => id}, socket) do
    if connected?(socket), do: Process.send_after(self(), :update, 5_000)

    event = Events.get_event!(id)
    Events.refresh_cache(event, false)
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

    {:ok, assign(socket,
      team_name: team_name || "",
      teams: teams,
      event: event,
      current_user_id: current_user_id
    )}
  end

  @impl true
  def handle_info(:update, socket) do
    Process.send_after(self(), :update, 30_000)
    Events.refresh_cache(event, false)

    teams = Teams.get_teams(socket.assigns.event)
    {:noreply, assign(socket, teams: teams)}
  end
end
