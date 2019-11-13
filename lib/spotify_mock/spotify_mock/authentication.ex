defmodule SpotifyMock.Authentication do
  def authenticate(%Spotify.Credentials{} = creds, %{"code" => code}) do
    {:ok, %Spotify.Credentials{access_token: "456", refresh_token: "789"}}
  end

  def url do
    "http://localhost:4000/callback?code=123"
  end
end
