defmodule Spoti.Repo.Migrations.CreateProfiles do
  use Ecto.Migration

  def change do
    create table(:profiles) do
      add :display_name, :string
      add :spotify_id, :string

      timestamps()
    end

    create unique_index(:profiles, [:spotify_id])
  end
end
