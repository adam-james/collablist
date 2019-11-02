defmodule SpotiWeb.Dashboard.PlaylistController do
  use SpotiWeb, :controller

  alias Spoti.Playlists

  def index(conn, _params) do
    profile = conn.assigns.current_user
    playlists = Playlists.list_profile_playlists(profile)
    render(conn, "index.html", playlists: playlists)
  end
end
