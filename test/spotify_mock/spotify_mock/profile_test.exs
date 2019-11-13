defmodule SpotifyMock.ProfileTest do
  use ExUnit.Case, async: true

  alias SpotifyMock.Profile

  describe "me/1" do
    test "returns mock spotify profile" do
      creds = %Spotify.Credentials{access_token: "123", refresh_token: "789"}
      {:ok, %Spotify.Profile{} = profile} = SpotifyMock.Profile.me(creds)

      assert profile.birthdate == "1987-09-18"
      assert profile.country == "US"
      assert profile.display_name == "Mock User"
      assert profile.email == "mock@example.com"
      assert profile.external_urls == "mock:uri"
      assert profile.followers == []
      assert profile.href == "mock:uri"
      assert profile.id == "abcdefg"
      assert profile.images == []
      assert profile.product == "premium"
      assert profile.type == "hold"
      assert profile.uri == "mock:uri:abcdefg"
    end
  end
end
