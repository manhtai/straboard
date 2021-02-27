defmodule Stravamate.Users.Activity do
  @moduledoc """
  Activity model
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Stravamate.Users.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "activities" do
    field(:name, :string)
    field(:uid, :string)
    field(:distance, :float)
    field(:moving_time, :integer)
    field(:elapsed_time, :integer)
    field(:average_speed, :float)
    field(:type, :string)

    field(:start_date, :utc_datetime)
    field(:start_date_local, :naive_datetime)

    belongs_to(:user, User, foreign_key: :user_id, references: :id, type: :binary_id)

    timestamps()
  end

  def changeset(activity_or_changeset, attrs) do
    activity_or_changeset
    |> cast(attrs, [
      :name,
      :uid,
      :user_id,
      :distance,
      :moving_time,
      :elapsed_time,
      :average_speed,
      :type,
      :start_date,
      :start_date_local
    ])
    |> validate_required([:name, :uid, :user_id])
  end
end
