defmodule SpotifyMock.Track do
  def get_tracks(creds, params) do
    {:ok,
     [
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
     ]}
  end
end
