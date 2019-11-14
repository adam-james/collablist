defmodule SpotiWeb.Dashboard.DashboardControllerTest do
  use SpotiWeb.ConnCase

  import Ecto.Query, warn: false

  alias Spoti.Repo
  alias Spoti.Playlists
  alias Spoti.Profiles.Profile

  def profile_fixture(attrs \\ %{}) do
    {:ok, profile} =
      %Profile{display_name: "Tester", spotify_id: "123"}
      |> Profile.changeset(attrs)
      |> Repo.insert()

    profile
  end

  def playlist_fixture(profile, attrs \\ %{}) do
    attrs = Enum.into(attrs, %{name: "Test Fixture Playlist", profile_id: profile.id})
    {:ok, playlist} = Playlists.create_playlist(attrs)
    playlist
  end

  describe "index" do
    setup %{conn: conn} do
      profile = profile_fixture()
      conn = Plug.Test.init_test_session(conn, user_id: profile.id)

      playlists =
        Enum.map(1..11, fn i ->
          playlist = playlist_fixture(profile, %{name: "Playlist #{i}"})
        end)

      %{conn: conn, playlists: playlists}
    end

    test "it lists ten most recent playlists", %{conn: conn, playlists: playlists} do
      conn = get(conn, Routes.dashboard_dashboard_path(conn, :index))
      resp = html_response(conn, 200)

      playlists
      |> Enum.take(10)
      |> Enum.each(fn playlist ->
        assert resp =~ playlist.name
      end)

      playlist11 = List.last(playlists)
      refute resp =~ playlist11.name
    end
  end
end
