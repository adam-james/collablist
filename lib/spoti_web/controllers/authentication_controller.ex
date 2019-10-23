defmodule SpotiWeb.AuthenticationController do
  use SpotiWeb, :controller
  
  def authenticate(conn, params) do
    case Spotify.Authentication.authenticate(conn, params) do
      {:ok, conn} -> redirect(conn, to: "/")
      {:error, _reason, conn} -> redirect(conn, to: "/error")
    end
  end
end
