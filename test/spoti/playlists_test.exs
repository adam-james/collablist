defmodule Spoti.PlaylistsTest do
  use Spoti.DataCase

  alias Spoti.Playlists
  alias Spoti.Repo

  describe "playlists" do
    alias Spoti.Profiles.Profile
    alias Spoti.Playlists.Playlist
    alias Spoti.Playlists.Track

    def profile_fixture(attrs \\ %{}) do
      {:ok, profile} =
        %Profile{display_name: "Tester", spotify_id: "123"}
        |> Profile.changeset(attrs)
        |> Repo.insert()

      profile
    end

    def playlist_fixture(profile) do
      attrs = %{name: "Test Fixture Playlist", profile_id: profile.id}
      {:ok, playlist} = Playlists.create_playlist(attrs)
      playlist
    end

    setup do
      profile = profile_fixture()
      playlist = playlist_fixture(profile)
      {:ok, profile: profile, playlist: playlist}
    end

    test "create_playlist/1 with valid data returns playlist", %{profile: profile} do
      attrs = %{name: "Test Playlist", profile_id: profile.id}

      assert {:ok, %Playlist{} = playlist} = Playlists.create_playlist(attrs)
      assert playlist.name == "Test Playlist"
      assert playlist.profile_id == profile.id
    end

    test "create_playlist/1 with invalid data returns error changeset" do
      attrs = %{name: "Test Playlist"}

      assert {:error, %Ecto.Changeset{}} = Playlists.create_playlist(attrs)
    end

    test "create_track/1 with valid data returns track", %{profile: profile, playlist: playlist} do
      attrs = %{spotify_id: "123", added_by_id: profile.id, playlist_id: playlist.id}

      assert {:ok, %Track{} = track} = Playlists.create_track(attrs)
      assert track.spotify_id == "123"
      assert track.added_by_id == profile.id
      assert track.playlist_id == playlist.id
    end

    test "create_track/1 with invalid data returns error changeset" do
      attrs = %{spotify_id: "123"}

      assert {:error, %Ecto.Changeset{}} = Playlists.create_track(attrs)
    end

    test "get_playlist!/1 returns playlist with given id", %{playlist: playlist} do
      found = Playlists.get_playlist!(playlist.id)
      assert found == playlist
    end

    test "list_profile_playlists/1 returns a profile's playlists", %{
      profile: profile,
      playlist: playlist
    } do
      assert Playlists.list_profile_playlists(profile) == [playlist]
    end

    test "change_playlist/1 returns a playlist changeset" do
      assert %Ecto.Changeset{} = Playlists.change_playlist(%Playlist{})
    end
  end

  describe "list_recent_playlists/0" do
    setup do
      profile = profile_fixture()

      playlists =
        Enum.map(1..11, fn _ ->
          playlist_fixture(profile)
        end)

      {:ok, profile: profile, playlists: playlists}
    end

    test "returns ten most recent playlists", %{playlists: playlists} do
      result = Playlists.list_recent_playlists()
      assert result == Enum.take(playlists, 10)
    end
  end
end
