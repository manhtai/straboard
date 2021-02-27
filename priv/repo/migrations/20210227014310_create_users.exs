defmodule Ahaboard.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add(:id, :binary_id, primary_key: true)

      add(:provider, :string, null: false)
      add(:uid, :string, null: false)

      add(:name, :string)
      add(:first_name, :string)
      add(:last_name, :string)

      add(:email, :string)
      add(:image, :string)

      add(:token, :string)
      add(:token_expires_at, :integer)
      add(:refresh_token, :string)
      add(:token_type, :string)

      timestamps()
    end

    create(unique_index(:users, [:provider, :uid]))
  end
end
