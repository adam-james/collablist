defmodule SpotiWeb.AuthorizationController do
  use SpotiWeb, :controller
  
  def authorize(conn, _params) do
    redirect conn, external: Spotify.Authorization.url
  end
end
