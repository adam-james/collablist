defmodule Spoti.Repo.Migrations.CreateCredentials do
  use Ecto.Migration

  def change do
    create table(:credentials) do
      add :access_token, :string, null: false
      add :refresh_token, :string, null: false
      add :profile_id, references(:profiles, on_delete: :nothing), null: false

      timestamps()
    end

    create index(:credentials, [:profile_id])
  end
end
