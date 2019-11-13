defmodule SpotifyMock.Search do
  def query(creds, params) do
    {:ok, %{items: [
      %Spotify.Track{
        album: %Spotify.Album{},
        artists: [%{"name" => "Artist One"}],
        id: "123",
        name: "Track One"
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
    ]}}
  end
end
