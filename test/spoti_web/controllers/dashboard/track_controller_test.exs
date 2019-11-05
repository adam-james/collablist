defmodule SpotiWeb.Dashboard.TrackControllerTest do
  use SpotiWeb.ConnCase

  alias Spoti.Repo
  alias Spoti.Playlists
  alias Spoti.Playlists.Track
  alias Spoti.Profiles.Profile

  def profile_fixture() do
    {:ok, profile} =
      %Profile{}
      |> Profile.changeset(%{display_name: "Test Profile", spotify_id: "123"})
      |> Repo.insert()

    profile
  end

  def playlist_fixture(attrs) do
    {:ok, playlist} = Playlists.create_playlist(attrs)
    playlist
  end

  describe "create track" do
    setup %{conn: conn} do
      profile = profile_fixture()
      playlist = playlist_fixture(%{name: "Test Playlist", profile_id: profile.id})
      conn = Plug.Test.init_test_session(conn, user_id: profile.id)
      {:ok, %{conn: conn, current_user: profile, playlist: playlist}}
    end

    test "redirects to playlist show when data is valid", %{
      conn: conn,
      playlist: playlist
    } do
      old_count = track_count()

      conn =
        post(conn, Routes.dashboard_playlist_track_path(conn, :create, playlist),
          spotify_id: "123"
        )

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.dashboard_playlist_path(conn, :show, id)

      assert track_count() == old_count + 1
    end
  end

  defp track_count() do
    Repo.aggregate(Track, :count, :id)
  end
end
