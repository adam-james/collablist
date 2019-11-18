defmodule Spoti.Playlists.Playlist do
  use Ecto.Schema
  import Ecto.Changeset

  alias Spoti.Playlists.Track

  schema "playlists" do
    field :name, :string
    field :profile_id, :id
    field :spotify_device_id, :string

    has_many :tracks, Track

    timestamps()
  end

  @doc false
  def changeset(playlist, attrs) do
    playlist
    |> cast(attrs, [:name, :profile_id, :spotify_device_id])
    |> validate_required([:name, :profile_id])
    |> foreign_key_constraint(:profile_id)
  end
end
