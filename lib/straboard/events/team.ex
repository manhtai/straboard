defmodule Straboard.Events.Team do
  @moduledoc """
  Team model
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Straboard.{Users.User, Events.Event, Events.EventTeamUser}

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
    field(:member_count, :integer, default: 0)
    field(:activity_count, :integer, default: 0)
    field(:total_distance, :float, default: 0.0)
    field(:average_speed, :float, default: 0.0)

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
      :average_speed,
      :total_distance
    ])
  end
end
