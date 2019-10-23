defmodule SpotiWeb.PageController do
  use SpotiWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
