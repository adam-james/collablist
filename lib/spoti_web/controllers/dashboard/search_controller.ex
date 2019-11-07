defmodule SpotiWeb.Dashboard.SearchController do
  use SpotiWeb, :controller
  import Phoenix.LiveView.Controller

  alias Spoti.Playlists

  def index(conn, %{"playlist_id" => playlist_id}) do
    profile = conn.assigns.current_user
    playlist = Playlists.get_playlist!(playlist_id)
    live_render(conn, SpotiWeb.Dashboard.SearchLive, session: %{profile: profile})
  end
end
