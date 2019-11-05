defmodule Spoti.Repo.Migrations.CreatePlaylistTracks do
  use Ecto.Migration

  def change do
    create table(:playlist_tracks) do
      add :spotify_id, :string
      add :playlist_id, references(:playlists, on_delete: :nothing), null: false
      add :added_by_id, references(:profiles, on_delete: :nothing), null: false

      timestamps()
    end

    create index(:playlist_tracks, [:playlist_id])
  end
end
