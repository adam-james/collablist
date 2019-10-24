defmodule SpotiWeb.Dashboard.DashboardController do
  use SpotiWeb, :controller

  def index(conn, _params) do
    profile = conn.assigns.current_user
    render(conn, "index.html", profile: profile)
  end  
end
