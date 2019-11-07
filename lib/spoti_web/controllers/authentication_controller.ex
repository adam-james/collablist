defmodule SpotiWeb.AuthenticationController do
  use SpotiWeb, :controller
  alias Spoti.Profiles
  alias Spoti.Auth

  def authenticate(conn, params) do
    # TODO handle errors
    {:ok, creds} = Spotify.Authentication.authenticate(%Spotify.Credentials{}, params)
    {:ok, spotify_profile} = Spotify.Profile.me(creds)
    {:ok, profile} = Profiles.find_or_create_profile(spotify_profile)

    {:ok, creds} =
      Auth.create_credential(%{
        access_token: creds.access_token,
        refresh_token: creds.refresh_token,
        profile_id: profile.id
      })

    conn
    |> put_session(:user_id, profile.id)
    |> redirect(to: "/dashboard")
  end
end
