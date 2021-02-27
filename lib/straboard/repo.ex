defmodule Straboard.Repo do
  use Ecto.Repo,
    otp_app: :straboard,
    adapter: Ecto.Adapters.Postgres
end
