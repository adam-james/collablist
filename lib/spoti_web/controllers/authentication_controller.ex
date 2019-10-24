defmodule SpotiWeb.AuthenticationController do
  use SpotiWeb, :controller
  alias Spoti.Profiles
  
  def authenticate(conn, params) do
    # TODO handle errors
    {:ok, conn} = Spotify.Authentication.authenticate(conn, params)
    {:ok, spotify_profile} = Spotify.Profile.me(conn)
    {:ok, profile} = Profiles.find_or_create_profile(spotify_profile)

    conn
      |> put_session(:user_id, profile.id)
      |> redirect(to: "/dashboard")
  end
end
