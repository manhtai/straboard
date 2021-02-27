defmodule Stravamate.Repo.Migrations.CreateActivities do
  use Ecto.Migration

  def change do
    create table(:activities, primary_key: false) do
      add(:id, :binary_id, primary_key: true)

      add(:name, :string)
      add(:uid, :string, null: false)
      add(:distance, :float)
      add(:moving_time, :integer)
      add(:elapsed_time, :integer)
      add(:average_speed, :float)
      add(:type, :string)
      add(:start_date, :utc_datetime)
      add(:start_date_local, :naive_datetime)

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

      timestamps()
    end

    create(unique_index(:activities, [:uid, :user_id]))
  end
end
