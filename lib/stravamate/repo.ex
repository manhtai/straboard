defmodule Stravamate.Repo do
  use Ecto.Repo,
    otp_app: :stravamate,
    adapter: Ecto.Adapters.Postgres
end
