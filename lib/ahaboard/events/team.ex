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

    timestamps()
  end

  def changeset(user_or_changeset, attrs) do
    user_or_changeset
    |> cast(attrs, [
      :name,
      :image,
      :user_id,
      :event_id
    ])
    |> validate_required([:name, :event_id, :user_id])
  end
end
