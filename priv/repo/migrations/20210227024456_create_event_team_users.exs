defmodule Ahaboard.Repo.Migrations.CreateEventTeamUsers do
  use Ecto.Migration

  def change do
    create table(:event_team_users, primary_key: false) do
      add(:id, :binary_id, primary_key: true)

      add(
        :user_id,
        references(
          :users,
          column: :id,
          type: :binary_id,
          on_delete: :delete_all
        ),
        null: false
      )

      add(
        :event_id,
        references(
          :events,
          column: :id,
          type: :binary_id,
          on_delete: :delete_all
        ),
        null: false
      )

      add(
        :team_id,
        references(
          :teams,
          column: :id,
          type: :binary_id,
          on_delete: :delete_all
        ),
        null: false
      )

      add(:event_role, :string)
      add(:team_role, :string)

      timestamps()
    end
  end
end
