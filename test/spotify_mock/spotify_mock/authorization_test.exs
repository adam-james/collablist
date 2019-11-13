defmodule SpotifyMock.AuthorizationTest do
  use ExUnit.Case, async: true

  describe "url/0" do
    test "returns callback url with code params" do
      assert SpotifyMock.Authentication.url() == "http://localhost:4000/callback?code=123"
    end
  end
end
