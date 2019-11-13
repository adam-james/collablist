defmodule SpotifyMock.SearchTest do
  use ExUnit.Case, async: true

  alias SpotifyMock.Search

  describe "query/2" do
    test "returns mock spotify tracks" do
      {:ok, %{items: items}} =
        SpotifyMock.Search.query(
          %Spotify.Credentials{access_token: "123", refresh_token: "789"},
          q: "whatever",
          type: "track"
        )

      assert items == [
        %Spotify.Track{
          album: %Spotify.Album{},
          artists: [%{"name" => "Artist One"}],
          id: "123",
          name: "Track One"
          # Additional fields
          # available_markets
          # disc_number
          # duration_ms
          # explicit
          # external_ids
          # href
          # is_playable
          # linked_from
          # popularity
          # preview_url
          # track_number
          # type
          # uri
        },
        %Spotify.Track{
          album: %Spotify.Album{},
          artists: [%{"name" => "Artist One"}],
          id: "456",
          name: "Track Two"
        },
        %Spotify.Track{
          album: %Spotify.Album{},
          artists: [%{"name" => "Artist One"}],
          id: "789",
          name: "Track Three"
        }
      ]
    end
  end
end
