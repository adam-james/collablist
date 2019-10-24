defmodule Spoti.Profiles.Profile do
  use Ecto.Schema
  import Ecto.Changeset

  schema "profiles" do
    field :display_name, :string
    field :spotify_id, :string

    timestamps()
  end

  @doc false
  def changeset(profile, attrs) do
    profile
    |> cast(attrs, [:display_name, :spotify_id])
    |> validate_required([:display_name, :spotify_id])
    |> unique_constraint(:spotify_id)
  end
end
