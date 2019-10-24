defmodule Spoti.Profiles do
  @moduledoc """
  The Profiles context.
  """

  import Ecto.Query, warn: false
  alias Spoti.Repo

  alias Spoti.Profiles.Profile

  @doc """
  Gets a single profile.

  Raises `Ecto.NoResultsError` if the Profile does not exist.

  ## Examples

      iex> get_profile!(123)
      %Profile{}

      iex> get_profile!(456)
      ** (Ecto.NoResultsError)

  """
  def get_profile!(id), do: Repo.get!(Profile, id)

  @doc """
  Finds a profile if it exists. Creates profile if it does not. 

  ## Examples

      iex> find_or_create_profile(%{field: value})
      {:ok, %Profile{}}

      iex> find_or_create_profile(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def find_or_create_profile(attrs \\ %{}) do
    case Repo.get_by(Profile, spotify_id: attrs.id) do
      nil -> create_profile(%{spotify_id: attrs.id, display_name: attrs.display_name})
      profile -> {:ok, profile}
    end
  end

  defp create_profile(attrs \\ %{}) do
    %Profile{}
    |> Profile.changeset(attrs)
    |> Repo.insert()
  end
end
