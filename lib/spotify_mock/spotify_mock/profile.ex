defmodule SpotifyMock.Profile do
  def me(%Spotify.Credentials{} = creds) do
    {:ok,
     %Spotify.Profile{
       birthdate: "1987-09-18",
       country: "US",
       display_name: "Mock User",
       email: "mock@example.com",
       external_urls: "mock:uri",
       followers: [],
       href: "mock:uri",
       id: "abcdefg",
       images: [],
       product: "premium",
       type: "hold",
       uri: "mock:uri:abcdefg"
     }}
  end
end
