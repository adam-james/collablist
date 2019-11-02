defmodule Spoti.PlaylistsTest do
  use Spoti.DataCase

  alias Spoti.Playlists
  alias Spoti.Repo

  describe "playlists" do
    alias Spoti.Profiles.Profile
    alias Spoti.Playlists.Playlist

    def profile_fixture() do
      Repo.insert!(%Profile{display_name: "Tester", spotify_id: "123"})
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
end
