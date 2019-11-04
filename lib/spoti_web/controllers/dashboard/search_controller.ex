defmodule SpotiWeb.Dashboard.SearchController do
  use SpotiWeb, :controller

  alias Spoti.Playlists

  def index(conn, %{"playlist_id" => playlist_id, "q" => q}) do
    profile = conn.assigns.current_user
    playlist = Playlists.get_profile_playlist!(profile, playlist_id)
    {:ok, %{items: items}} = Spotify.Search.query(conn, q: q, type: "track")
    render(conn, "index.html", items: items, playlist: playlist)
  end

  def index(conn, %{"playlist_id" => playlist_id}) do
    profile = conn.assigns.current_user
    playlist = Playlists.get_profile_playlist!(profile, playlist_id)
    render(conn, "index.html", items: [], playlist: playlist)
  end
end
