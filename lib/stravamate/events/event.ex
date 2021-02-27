defmodule Stravamate.Events.Event do
  @moduledoc """
  Event model
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Stravamate.{Users.User, Events.Team, Events.EventTeamUser}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "events" do
    field(:name, :string)
    field(:code, :string)
    field(:image, :string)

    field(:type, :string, default: "Run")
    field(:start_date, :date)
    field(:end_date, :date)
    field(:location, :string)

    belongs_to(:user, User, foreign_key: :user_id, references: :id, type: :binary_id)
    has_many(:teams, Team)

    has_many(:event_team_users, EventTeamUser)
    has_many(:users, through: [:event_team_users, :event])

    timestamps()
  end

  def changeset(event_or_changeset, attrs) do
    event_or_changeset
    |> cast(attrs, [
      :name,
      :code,
      :image,
      :start_date,
      :end_date,
      :location,
      :user_id
    ])
    |> validate_required([:name, :code, :user_id])
    |> unique_constraint(:code)
  end

  def clean_code(changeset) do
    code = get_field(changeset, :code)

    code =
      code
      |> String.downcase()
      |> String.replace(~r"[^a-z\d]+", "-")

    put_change(changeset, :code, code)
  end
end
