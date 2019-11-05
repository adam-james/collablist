defmodule SpotiWeb.Router do
  use SpotiWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :dashboard do
    plug :put_layout, {SpotiWeb.DashboardView, :dashboard}
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SpotiWeb do
    pipe_through :browser

    # TODO remove later
    resources "/todos", TodoController

    get "/", PageController, :index
    get "/authorize", AuthorizationController, :authorize
    get "/callback", AuthenticationController, :authenticate
  end

  scope "/dashboard", SpotiWeb.Dashboard, as: :dashboard do
    pipe_through [:browser, :authenticate_user, :dashboard]

    get "/", DashboardController, :index

    resources "/playlists", PlaylistController, only: [:index, :new, :create, :show] do
      get "/search", SearchController, :index
      resources "/tracks", TrackController, only: [:create]
    end
  end

  defp authenticate_user(conn, _) do
    case get_session(conn, :user_id) do
      nil ->
        conn
        |> Phoenix.Controller.put_flash(:error, "You must be logged in to view that page.")
        |> Phoenix.Controller.redirect(to: "/")
        |> halt()

      user_id ->
        # TODO rethink profile/user naming. just have one name
        assign(conn, :current_user, Spoti.Profiles.get_profile!(user_id))
    end
  end
end
