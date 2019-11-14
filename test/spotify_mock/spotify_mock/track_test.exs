defmodule SpotifyMock.TrackTest do
  use ExUnit.Case, async: true

  describe "me/1" do
    test "returns mock spotify profile" do
      creds = %Spotify.Credentials{access_token: "123", refresh_token: "789"}
      {:ok, tracks} = SpotifyMock.Track.get_tracks(creds, [])

      assert tracks == [
               %Spotify.Track{
                 album: %Spotify.Album{},
                 artists: [%{"name" => "Artist Two"}],
                 id: "321",
                 name: "Track Four"
               },
               %Spotify.Track{
                 album: %Spotify.Album{},
                 artists: [%{"name" => "Artist Two"}],
                 id: "654",
                 name: "Track Five"
               },
               %Spotify.Track{
                 album: %Spotify.Album{},
                 artists: [%{"name" => "Artist Two"}],
                 id: "987",
                 name: "Track Six"
               }
             ]
    end
  end
end
