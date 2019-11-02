defmodule SpotiWeb.Dashboard.PlaylistController do
  use SpotiWeb, :controller

  alias Spoti.Playlists
  alias Spoti.Playlists.Playlist

  def index(conn, _params) do
    profile = conn.assigns.current_user
    playlists = Playlists.list_profile_playlists(profile)
    render(conn, "index.html", playlists: playlists)
  end

  def new(conn, _params) do
    changeset = Playlists.change_playlist(%Playlist{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"playlist" => playlist_params}) do
    profile = conn.assigns.current_user
    params = Map.put(playlist_params, "profile_id", profile.id)

    case Playlists.create_playlist(params) do
      {:ok, _playlist} ->
        conn
        |> put_flash(:info, "Playlist created.")
        |> redirect(to: Routes.dashboard_playlist_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end
