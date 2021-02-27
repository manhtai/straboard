defmodule Stravamate.Repo.Migrations.CreateTeams do
  use Ecto.Migration

  def change do
    create table(:teams, primary_key: false) do
      add(:id, :binary_id, primary_key: true)

      add(:name, :string, null: false)
      add(:image, :string)

      add(:member_count, :integer, default: 0)
      add(:activity_count, :integer, default: 0)
      add(:total_distance, :float, default: 0.0)

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

      timestamps()
    end

    create(unique_index(:teams, [:event_id, :name]))
  end
end
