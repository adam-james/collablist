defmodule SpotiWeb.Dashboard.TrackController do
  use SpotiWeb, :controller

  alias Spoti.Playlists

  def create(conn, %{"spotify_id" => spotify_id, "playlist_id" => playlist_id}) do
    profile = conn.assigns.current_user

    params = %{
      "spotify_id" => spotify_id,
      "playlist_id" => playlist_id,
      "added_by_id" => profile.id
    }

    case Playlists.create_track(params) do
      {:ok, track} ->
        conn
        |> put_flash(:info, "Track created.")
        |> redirect(to: Routes.dashboard_playlist_path(conn, :show, track.playlist_id))
    end
  end
end
