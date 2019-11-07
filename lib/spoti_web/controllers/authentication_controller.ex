defmodule SpotiWeb.AuthenticationController do
  use SpotiWeb, :controller
  alias Spoti.Profiles
  alias Spoti.Auth

  def authenticate(conn, params) do
    profile =
      params
      |> get_creds()
      |> find_or_create_profile()

    conn
    |> put_session(:user_id, profile.id)
    |> redirect(to: "/dashboard")
  end

  defp get_creds(params) do
    Spotify.Authentication.authenticate(%Spotify.Credentials{}, params)
  end

  defp find_or_create_profile({:ok, creds}) do
    creds
    |> get_spotify_profile()
    |> find_or_create()
    |> upsert_creds(creds)
  end

  defp get_spotify_profile(creds) do
    Spotify.Profile.me(creds)
  end

  defp find_or_create({:ok, spotify_profile}) do
    Profiles.find_or_create_profile(spotify_profile)
  end

  defp upsert_creds({:ok, profile}, creds) do
    {:ok, creds} =
      Auth.upsert_credential(%{
        access_token: creds.access_token,
        refresh_token: creds.refresh_token,
        profile_id: profile.id
      })

    profile
  end
end
