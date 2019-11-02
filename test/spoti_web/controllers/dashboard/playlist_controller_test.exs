defmodule SpotiWeb.Dashboard.PlaylistControllerTest do
  use SpotiWeb.ConnCase

  alias Spoti.Repo
  alias Spoti.Playlists
  alias Spoti.Playlists.Playlist
  alias Spoti.Profiles.Profile

  # TODO create a test later to ensure this isn't accessible when not logged in

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

  describe "index" do
    setup %{conn: conn} do
      profile = profile_fixture()
      conn = Plug.Test.init_test_session(conn, user_id: profile.id)

      playlist1 = playlist_fixture(%{name: "Playlist One", profile_id: profile.id})
      playlist2 = playlist_fixture(%{name: "Playlist Two", profile_id: profile.id})

      {:ok, %{conn: conn, current_user: profile, playlist1: playlist1, playlist2: playlist2}}
    end

    test "lists all playlists for profile", %{
      conn: conn,
      playlist1: playlist1,
      playlist2: playlist2
    } do
      conn = get(conn, Routes.dashboard_playlist_path(conn, :index))
      resp = html_response(conn, 200)

      assert resp =~ "Your Playlists"
      assert resp =~ playlist1.name
      assert resp =~ playlist2.name
    end
  end

  describe "new playlist" do
    setup %{conn: conn} do
      profile = profile_fixture()
      conn = Plug.Test.init_test_session(conn, user_id: profile.id)
      {:ok, %{conn: conn, current_user: profile}}
    end

    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.dashboard_playlist_path(conn, :new))
      resp = html_response(conn, 200)

      assert resp =~ "New Playlist"
    end
  end

  describe "create playlist" do
    setup %{conn: conn} do
      profile = profile_fixture()
      conn = Plug.Test.init_test_session(conn, user_id: profile.id)
      {:ok, %{conn: conn, current_user: profile}}
    end

    test "redirects to show when data is valid", %{conn: conn} do
      attrs = %{name: "Test Playlist"}
      conn = post(conn, Routes.dashboard_playlist_path(conn, :create), playlist: attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.dashboard_playlist_path(conn, :show, id)

      conn = get(conn, Routes.dashboard_playlist_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Test Playlist"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.dashboard_playlist_path(conn, :create), playlist: %{})
      assert html_response(conn, 200) =~ "New Playlist"
    end
  end
end
