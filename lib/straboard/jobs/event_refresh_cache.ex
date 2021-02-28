defmodule Straboard.EventRefreshCache do
  @moduledoc """
  Refresh event leaderboard job
  """

  use Oban.Worker,
    queue: :default,
    priority: 3,
    max_attempts: 1,
    tags: ["cache"],
    unique: [fields: [:args], keys: [:event_id], period: 30]

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"event_id" => event_id} = _args}) do
    Events.calculate_team_stats(event_id)
    :ok
  end
end
