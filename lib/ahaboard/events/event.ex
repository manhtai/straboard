defmodule Ahaboard.Events.Event do
  @moduledoc """
  Event model
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Ahaboard.{Users.User, Events.Team, Events.EventTeamUser}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "events" do
    field(:name, :string)
    field(:code, :string)
    field(:image, :string)

    field(:start_date, :date)
    field(:end_date, :date)
    field(:location, :string)

    belongs_to(:user, User, foreign_key: :user_id, references: :id, type: :binary_id)
    has_many(:teams, Team)

    has_many(:event_team_users, EventTeamUser)
    has_many(:users, through: [:event_team_users, :event])

    timestamps()
  end

  def changeset(user_or_changeset, attrs) do
    user_or_changeset
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
    code = Regex.replace(~r/[^a-z\d]+/, code, fn _, _match -> "-" end)
           |> String.downcase()
    put_change(changeset, :code, code)
  end
end
