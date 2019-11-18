defmodule Spoti.Repo.Migrations.AddDeviceToPlaylist do
  use Ecto.Migration

  def change do
    alter table(:playlists) do
      add :spotify_device_id, :string
    end
  end
end
