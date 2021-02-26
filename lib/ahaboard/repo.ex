defmodule Ahaboard.Repo do
  use Ecto.Repo,
    otp_app: :ahaboard,
    adapter: Ecto.Adapters.Postgres
end
