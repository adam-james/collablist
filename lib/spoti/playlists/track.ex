defmodule Spoti.Playlists.Track do
  use Ecto.Schema
  import Ecto.Changeset

  alias Spoti.Playlists.Playlist

  schema "playlist_tracks" do
    field :spotify_id, :string
    field :added_by_id, :id

    belongs_to :playlist, Playlist

    timestamps()
  end

  @doc false
  def changeset(track, attrs) do
    track
    |> cast(attrs, [:spotify_id, :playlist_id, :added_by_id])
    |> validate_required([:spotify_id, :playlist_id, :added_by_id])
    |> foreign_key_constraint(:playlist_id)
    |> foreign_key_constraint(:added_by_id)
  end
end
