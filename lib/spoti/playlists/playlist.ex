defmodule Spoti.Playlists.Playlist do
  use Ecto.Schema
  import Ecto.Changeset

  schema "playlists" do
    field :name, :string
    field :profile_id, :id

    timestamps()
  end

  @doc false
  def changeset(playlist, attrs) do
    playlist
    |> cast(attrs, [:name, :profile_id])
    |> validate_required([:name, :profile_id])
    |> foreign_key_constraint(:profile_id)
  end
end
