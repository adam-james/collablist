defmodule Spoti.Auth.Credential do
  use Ecto.Schema
  import Ecto.Changeset

  schema "credentials" do
    field :access_token, :string
    field :refresh_token, :string
    field :profile_id, :id

    timestamps()
  end

  @doc false
  def changeset(credential, attrs) do
    credential
    |> cast(attrs, [:access_token, :refresh_token, :profile_id])
    |> validate_required([:access_token, :refresh_token, :profile_id])
    |> foreign_key_constraint(:profile_id)
  end
end
