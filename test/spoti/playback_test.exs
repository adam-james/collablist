defmodule Spoti.PlaybackTest do
  use Spoti.DataCase

  import Mock

  alias Spoti.Playback
  alias Spoti.Playback.PlaybackRegistry
  alias Spoti.Playback.PlaybackServer

  describe "ensure_playback_started/1" do
    test "it returns already started playback" do
      with_mocks [
        {PlaybackRegistry, [], [get_playback: fn 123 -> "fake-pid" end]},
        {PlaybackServer, [], [get_state: fn "fake-pid" -> %PlaybackServer{playlist_id: 123} end]}
      ] do
        {:ok, playback} = Playback.ensure_playback_started(123)
        assert playback == %PlaybackServer{playlist_id: 123}
      end
    end

    test "starts new playback if not started" do
      with_mocks [
        {PlaybackRegistry, [],
         [
           get_playback: fn 123 -> nil end,
           start_playback: fn 123 -> {:ok, "fake-pid"} end
         ]},
        {PlaybackServer, [], [get_state: fn "fake-pid" -> %PlaybackServer{playlist_id: 123} end]}
      ] do
        {:ok, playback} = Playback.ensure_playback_started(123)
        assert playback == %PlaybackServer{playlist_id: 123}
      end
    end

    test "returns error if cannot start playback" do
      with_mocks [
        {PlaybackRegistry, [],
         [
           get_playback: fn 123 -> nil end,
           start_playback: fn 123 -> {:error, :alreadystarted} end
         ]}
      ] do
        assert {:error, :alreadystarted} = Playback.ensure_playback_started(123)
      end
    end
  end

  describe "play/1" do
    test "returns error when playback not found" do
      with_mocks [
        {PlaybackRegistry, [],
         [
           get_playback: fn 123 -> nil end
         ]}
      ] do
        assert {:error, "Playback not found."} = Playback.play(123)
      end
    end

    test "calls PlaybackServer.play when playback found" do
      with_mocks [
        {PlaybackRegistry, [],
         [
           get_playback: fn 123 -> "fake-pid" end
         ]},
        {PlaybackServer, [],
         [
           play: fn "fake-pid" -> %PlaybackServer{playlist_id: 123, is_playing: true} end
         ]}
      ] do
        assert {:ok, %PlaybackServer{playlist_id: 123, is_playing: true}} = Playback.play(123)
        assert_called(PlaybackServer.play("fake-pid"))
      end
    end
  end

  describe "pause/1" do
    test "returns error when playback not found" do
      with_mocks [
        {PlaybackRegistry, [],
         [
           get_playback: fn 123 -> nil end
         ]}
      ] do
        assert {:error, "Playback not found."} = Playback.pause(123)
      end
    end

    test "calls PlaybackServer.play when playback found" do
      with_mocks [
        {PlaybackRegistry, [],
         [
           get_playback: fn 123 -> "fake-pid" end
         ]},
        {PlaybackServer, [],
         [
           pause: fn "fake-pid" -> %PlaybackServer{playlist_id: 123, is_playing: false} end
         ]}
      ] do
        assert {:ok, %PlaybackServer{playlist_id: 123, is_playing: false}} = Playback.pause(123)
        assert_called(PlaybackServer.pause("fake-pid"))
      end
    end
  end

  describe "add_track/2" do
    test "returns error when playback not found" do
      with_mocks [
        {PlaybackRegistry, [],
         [
           get_playback: fn 123 -> nil end
         ]}
      ] do
        track = %Spotify.Track{}
        assert {:error, "Playback not found."} = Playback.add_track(123, track)
      end
    end

    test "calls PlaybackServer.play when playback found" do
      with_mocks [
        {PlaybackRegistry, [],
         [
           get_playback: fn 123 -> "fake-pid" end
         ]},
        {PlaybackServer, [],
         [
           add_track: fn "fake-pid", _track ->
             %PlaybackServer{playlist_id: 123, is_playing: false}
           end
         ]}
      ] do
        track = %Spotify.Track{}

        assert {:ok, %PlaybackServer{playlist_id: 123, is_playing: false}} =
                 Playback.add_track(123, track)

        assert_called(PlaybackServer.add_track("fake-pid", track))
      end
    end
  end
end
