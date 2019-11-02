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
      {:ok, playlist} ->
        conn
        |> put_flash(:info, "Playlist created.")
        |> redirect(to: Routes.dashboard_playlist_path(conn, :show, playlist))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    profile = conn.assigns.current_user
    playlist = Playlists.get_profile_playlist!(profile, id)
    render(conn, "show.html", playlist: playlist)    
  end
end
