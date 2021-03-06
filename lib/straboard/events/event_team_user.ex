defmodule Straboard.Events.EventTeamUser do
  @moduledoc """
  Event-Team-User many-to-many model
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Straboard.{Users.User, Events.Event, Events.Team}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "event_team_users" do
    belongs_to(:user, User, foreign_key: :user_id, references: :id, type: :binary_id)
    belongs_to(:event, Event, foreign_key: :event_id, references: :id, type: :binary_id)
    belongs_to(:team, Team, foreign_key: :team_id, references: :id, type: :binary_id)

    field(:event_role, :string)
    field(:team_role, :string)

    timestamps()
  end

  def changeset(user_or_changeset, attrs) do
    user_or_changeset
    |> cast(attrs, [
      :user_id,
      :event_id,
      :event_role,
      :team_id,
      :team_role
    ])
    |> validate_required([:event_id, :user_id, :event_role])
  end
end
