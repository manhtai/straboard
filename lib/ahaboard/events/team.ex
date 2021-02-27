defmodule Ahaboard.Events.Team do
  @moduledoc """
  Team model
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Ahaboard.{Users.User, Events.Event, Events.EventTeamUser}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "teams" do
    field(:name, :string)
    field(:image, :string)

    belongs_to(:user, User, foreign_key: :user_id, references: :id, type: :binary_id)
    belongs_to(:event, Event, foreign_key: :event_id, references: :id, type: :binary_id)

    has_many(:event_team_users, EventTeamUser)
    has_many(:users, through: [:event_team_users, :team])

    # Cache fields
    field(:member_count, :integer)
    field(:activity_count, :integer)
    field(:total_distance, :float)

    timestamps()
  end

  def changeset(team_or_changeset, attrs) do
    team_or_changeset
    |> cast(attrs, [
      :name,
      :image,
      :user_id,
      :event_id
    ])
    |> validate_required([:name, :event_id, :user_id])
  end

  def changeset_cache(team, attrs) do
    team
    |> cast(attrs, [
      :member_count,
      :activity_count,
      :total_distance,
    ])
  end
end
