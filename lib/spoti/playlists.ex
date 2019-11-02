defmodule Spoti.Playlists do
  @moduledoc """
  The Playlists context.
  """

  import Ecto.Query, warn: false
  alias Spoti.Repo

  alias Spoti.Profiles.Profile
  alias Spoti.Playlists.Playlist

  @doc """
  Returns playlists belonging to a profile.

  ## Examples

      iex> list_profile_playlists(profile)
      [%Playlist{}, ...]
  """
  def list_profile_playlists(%Profile{} = profile) do
    Repo.all(from p in Playlist, where: p.profile_id == ^profile.id)
  end

  def change_playlist(%Playlist{} = playlist) do
    Playlist.changeset(playlist, %{})
  end

  @doc """
  Creates a playlist.

  ## Examples

      iex> create_playlist(%{field: value})
      {:ok, %Playlist{}}

      iex> create_playlist(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_playlist(attrs \\ %{}) do
    %Playlist{}
    |> Playlist.changeset(attrs)
    |> Repo.insert()
  end
end
