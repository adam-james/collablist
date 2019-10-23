defmodule SpotiWeb.Router do
  use SpotiWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SpotiWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/authorize", AuthorizationController, :authorize
    get "/callback", AuthenticationController, :authenticate
    get "/search", SearchController, :index
    post "/search", SearchController, :search
  end

  # Other scopes may use custom stacks.
  # scope "/api", SpotiWeb do
  #   pipe_through :api
  # end
end
