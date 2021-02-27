defmodule Ahaboard.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events, primary_key: false) do
      add(:id, :binary_id, primary_key: true)

      add(:name, :string, null: false)
      add(:code, :string, null: false)
      add(:image, :string)

      add(:start_date, :date)
      add(:end_date, :date)
      add(:location, :string)

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

    create(unique_index(:events, [:code]))
  end
end
