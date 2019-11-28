defmodule Spoti.Playback.PlaybackServerTest do
  use Spoti.DataCase

  # NOTE to exclude tests that sleep and thus take more time,
  # run `mix test --exclude sleeps`.

  import Mock

  alias Spoti.Auth
  alias Spoti.Playback.PlaybackServer
  alias Spoti.Playlists
  alias Spoti.Profiles

  setup_with_mocks [
    {Spotify.Track, [], [get_tracks: fn _, _ -> {:ok, [%Spotify.Track{}]} end]},
    {Spotify.Player, [], [play: fn _, _ -> :ok end, pause: fn _ -> :ok end]}
  ] do
    {:ok, profile} = Profiles.find_or_create_profile(%{id: "123", display_name: "Tester"})

    {:ok, _} =
      Auth.create_credential(%{profile_id: profile.id, access_token: "123", refresh_token: "456"})

    {:ok, playlist} = Playlists.create_playlist(%{profile_id: profile.id, name: "Test Playlist"})

    {:ok, _track} =
      Playlists.create_track(%{
        spotify_id: "789",
        added_by_id: profile.id,
        playlist_id: playlist.id
      })

    {:ok, pid} = PlaybackServer.start_link(playlist.id)

    {:ok, playlist: playlist, profile: profile, pid: pid}
  end

  describe "get_state/1" do
    test "returns state", %{playlist: playlist, pid: pid} do
      state = PlaybackServer.get_state(pid)
      assert state == %PlaybackServer{playlist_id: playlist.id, current_track: %Spotify.Track{}}
    end
  end

  describe "play/1" do
    test "it does not play when no current track", %{pid: pid} do
      :sys.replace_state(pid, fn state -> %{state | current_track: nil} end)
      next_state = PlaybackServer.play(pid)
      assert next_state.current_track == nil
      assert next_state.is_playing == false
    end

    test "it plays when current track", %{pid: pid} do
      next_state = PlaybackServer.play(pid)
      assert next_state.current_track == %Spotify.Track{}
      assert next_state.is_playing == true
      assert is_reference(next_state.timer_ref)
      assert_called(Spotify.Player.play(:_, :_))
    end
  end

  describe "pause/1" do
    test "pauses playback", %{pid: pid} do
      next_state = PlaybackServer.play(pid)
      assert next_state.is_playing == true
      {:ok, next_state2} = PlaybackServer.pause(pid)
      assert next_state2.is_playing == false
      assert next_state2.timer_ref == nil
    end

    test "returns Spotify error", %{pid: pid} do
      with_mock Spotify.Player,
        play: fn _, _ -> :ok end,
        pause: fn _ -> {:error, "Could not pause."} end do
        next_state = PlaybackServer.play(pid)
        {:error, "Could not pause."} = PlaybackServer.pause(pid)
        next_state2 = PlaybackServer.get_state(pid)
        assert next_state2.is_playing == true
        assert is_reference(next_state.timer_ref)
      end
    end
  end
end
