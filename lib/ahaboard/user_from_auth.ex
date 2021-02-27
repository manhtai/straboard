defmodule Ahaboard.UserFromAuth do
  @moduledoc """
  Retrieve the user information from an auth request
  """
  require Logger
  require Jason

  alias Ueberauth.Auth
  alias Ecto.Changeset

  alias AhaboardWeb.ErrorHelpers
  alias Ahaboard.Users

  def find_or_create(%Auth{} = auth) do
    basic_attrs = basic_info(auth)

    attrs =
      basic_attrs
      |> Map.merge(%{
        token: auth.credentials.token,
        token_expires_at: auth.credentials.expires_at,
        token_type: auth.credentials.token_type,
        refresh_token: auth.credentials.refresh_token
      })

    case Users.get_or_create(attrs) do
      {:ok, user} ->
        {:ok, user}

      {:error, changeset} ->
        errors = Changeset.traverse_errors(changeset, &ErrorHelpers.translate_error/1)
        {:error, errors}
    end
  end

  defp avatar_from_auth(%{info: %{image: image}}), do: image

  # default case if nothing matches
  defp avatar_from_auth(auth) do
    Logger.warn("#{auth.provider} needs to find an avatar URL!")
    Logger.debug(Jason.encode!(auth))
    nil
  end

  defp basic_info(auth) do
    %{
      provider: Atom.to_string(auth.provider),
      uid: auth.uid,
      name: name_from_auth(auth),
      first_name: auth.info.first_name,
      last_name: auth.info.last_name,
      email: auth.info.email,
      image: avatar_from_auth(auth)
    }
  end

  defp name_from_auth(auth) do
    if auth.info.name do
      auth.info.name
    else
      name =
        [auth.info.first_name, auth.info.last_name]
        |> Enum.filter(&(&1 != nil and &1 != ""))

      if Enum.empty?(name) do
        auth.info.nickname
      else
        Enum.join(name, " ")
      end
    end
  end
end
