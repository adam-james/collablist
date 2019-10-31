defmodule Spoti.Repo.Migrations.CreateProfiles do
  use Ecto.Migration

  def change do
    create table(:profiles) do
      add :display_name, :string, null: false
      add :spotify_id, :string, null: false

      timestamps()
    end

    create unique_index(:profiles, [:spotify_id])
  end
end
