defmodule SpotifyMock.AuthenticationTest do
  use ExUnit.Case, async: true

  alias SpotifyMock.Authentication

  describe "authenticate/2" do
    test "returns mock spotify credentials" do
      params = %{"code" => "123"}

      {:ok, %Spotify.Credentials{} = creds} =
        SpotifyMock.Authentication.authenticate(%Spotify.Credentials{}, params)

      assert creds.access_token == "456"
      assert creds.refresh_token == "789"
    end
  end

  describe "url/0" do
    test "returns callback url with code params" do
    assert SpotifyMock.Authentication.url() == "http://localhost:4000/callback?code=123"
    end
  end
end
