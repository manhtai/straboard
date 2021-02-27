defmodule Ahaboard.Users.User do
  @moduledoc """
  User model
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field(:provider, :string)
    field(:uid, :string)

    field(:name, :string)
    field(:first_name, :string)
    field(:last_name, :string)

    field(:email, :string)
    field(:image, :string)

    field(:token, :string)
    field(:token_expires_at, :integer)
    field(:refresh_token, :string)
    field(:token_type, :string)

    timestamps()
  end

  def changeset(user_or_changeset, attrs) do
    user_or_changeset
    |> cast(attrs, [
      :provider,
      :uid,
      :name,
      :first_name,
      :last_name,
      :email,
      :image,
      :token,
      :token_expires_at,
      :refresh_token,
      :token_type
    ])
    |> validate_required([:provider, :uid])
  end

  def refresh_token_changeset(user, attrs) do
    user
    |> cast(attrs, [
      :token,
      :token_expires_at,
      :refresh_token,
      :token_type
    ])
    |> validate_required([:token, :refresh_token])
  end
end
