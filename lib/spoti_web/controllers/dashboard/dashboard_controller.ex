defmodule SpotiWeb.Dashboard.DashboardController do
  use SpotiWeb, :controller

  alias Spoti.Playlists

  def index(conn, _params) do
    profile = conn.assigns.current_user
    playlists = Playlists.list_profile_playlists(profile)
    render(conn, "index.html", profile: profile, playlists: playlists)
  end
end
