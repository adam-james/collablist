defmodule Spoti.Playlists do
  @moduledoc """
  The Playlists context.
  """

  import Ecto.Query, warn: false
  alias Spoti.Repo

  alias Spoti.Profiles.Profile
  alias Spoti.Playlists.Playlist
  alias Spoti.Playlists.Track

  @doc """
  Returns playlists belonging to a profile.

  ## Examples

      iex> list_profile_playlists(profile)
      [%Playlist{}, ...]
  """
  def list_profile_playlists(%Profile{} = profile) do
    Repo.all(from p in Playlist, where: p.profile_id == ^profile.id)
  end

  def get_playlist!(id), do: Repo.get!(Playlist, id)

  def change_playlist(%Playlist{} = playlist) do
    Playlist.changeset(playlist, %{})
  end

  def create_track(attrs \\ %{}) do
    %Track{}
    |> Track.changeset(attrs)
    |> Repo.insert()
  end

  def get_spotify_tracks(creds, playlist) do
    ids =
      Repo.all(
        from t in Track,
          where: t.playlist_id == ^playlist.id,
          select: t.spotify_id,
          order_by: t.inserted_at
      )
      |> Enum.join(",")

    if String.length(ids) > 0 do
      # TODO this has a limit of 50 ids
      SpotifyMock.Track.get_tracks(creds, ids: ids)
    else
      {:ok, []}
    end
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
