defmodule Spoti.Playback.PlaybackServerTest do
  use ExUnit.Case, async: true

  # NOTE to exclude tests that sleep and thus take more time,
  # run `mix test --exclude sleeps`.

  alias Spoti.Playback.PlaybackServer

  describe "start_link/1" do
    test "returns pid" do
      playlist_id = 123
      {:ok, pid} = PlaybackServer.start_link(playlist_id)
      assert is_pid(pid)
    end
  end

  describe "get_state/1" do
    test "returns state" do
      playlist_id = 123
      {:ok, pid} = PlaybackServer.start_link(playlist_id)
      state = PlaybackServer.get_state(pid)
      assert state == %PlaybackServer{playlist_id: playlist_id}
    end
  end

  describe "play/1" do
    setup do
      playlist_id = 123
      {:ok, pid} = PlaybackServer.start_link(playlist_id)
      state = PlaybackServer.get_state(pid)
      {:ok, pid: pid, state: state}
    end

    test "sets is_playing to true", %{pid: pid} do
      next_state = PlaybackServer.play(pid)
      assert next_state.is_playing == true
      assert PlaybackServer.get_state(pid).is_playing == true
    end

    test "sets time_ref", %{pid: pid} do
      next_state = PlaybackServer.play(pid)
      assert is_reference(next_state.timer_ref)
      assert is_reference(PlaybackServer.get_state(pid).timer_ref)
    end

    @tag :sleeps
    test "starts progress", %{pid: pid} do
      # TODO can you mock time instead of sleeping?
      PlaybackServer.play(pid)
      :timer.sleep(1000)
      state = PlaybackServer.get_state(pid)
      assert state.progress_ms == 1000
      :timer.sleep(1000)
      state2 = PlaybackServer.get_state(pid)
      assert state2.progress_ms == 2000
    end
  end

  describe "pause/1" do
    setup do
      playlist_id = 123
      {:ok, pid} = PlaybackServer.start_link(playlist_id)
      state = PlaybackServer.get_state(pid)
      {:ok, pid: pid, state: state}
    end

    test "sets is_playing to false", %{pid: pid} do
      next_state = PlaybackServer.play(pid)
      assert next_state.is_playing == true
      next_state2 = PlaybackServer.pause(pid)
      assert next_state2.is_playing == false
      assert PlaybackServer.get_state(pid).is_playing == false
    end

    test "removes time_ref", %{pid: pid} do
      next_state = PlaybackServer.play(pid)
      assert is_reference(next_state.timer_ref)
      next_state2 = PlaybackServer.pause(pid)
      assert next_state2.timer_ref == nil
      assert PlaybackServer.get_state(pid).timer_ref == nil
    end

    @tag :sleeps
    test "stops progress", %{pid: pid} do
      PlaybackServer.play(pid)
      :timer.sleep(1000)
      state = PlaybackServer.get_state(pid)
      assert state.progress_ms == 1000
      PlaybackServer.pause(pid)
      :timer.sleep(1000)
      state2 = PlaybackServer.get_state(pid)
      assert state2.progress_ms == 1000
    end
  end
end
