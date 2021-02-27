defmodule Ahaboard.Events.EventTeamUser do
  @moduledoc """
  Event-Team-User many-to-many model
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Ahaboard.{Users.User, Events.Event, Events.Team}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "events" do
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
      :name,
      :image,
      :user_id,
      :event_id
    ])
    |> validate_required([:name, :image, :event_id, :user_id])
  end
end
