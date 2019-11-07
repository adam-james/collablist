defmodule Spoti.Auth do
  @moduledoc """
  The Auth context.
  """

  import Ecto.Query, warn: false
  alias Spoti.Repo

  alias Spoti.Auth.Credential
  alias Spoti.Profiles.Profile

  def get_credentials!(%Profile{id: id} = profile) do
    creds = Repo.one!(from c in Credential, where: c.id == ^id)
    %Spotify.Credentials{access_token: creds.access_token, refresh_token: creds.refresh_token}
  end

  @doc """
  Creates a credential.

  ## Examples

      iex> create_credential(%{field: value})
      {:ok, %Credential{}}

      iex> create_credential(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_credential(attrs \\ %{}) do
    %Credential{}
    |> Credential.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a credential.

  ## Examples

      iex> update_credential(credential, %{field: new_value})
      {:ok, %Credential{}}

      iex> update_credential(credential, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_credential(%Credential{} = credential, attrs) do
    credential
    |> Credential.changeset(attrs)
    |> Repo.update()
  end
end
