defmodule SpotiWeb.Dashboard.DashboardController do
  use SpotiWeb, :controller

  alias Spoti.Playlists

  def index(conn, _params) do
    profile = conn.assigns.current_user
    playlists = Playlists.list_recent_playlists()
    render(conn, "index.html", profile: profile, playlists: playlists)
  end
end
