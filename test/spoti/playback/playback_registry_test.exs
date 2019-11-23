defmodule Spoti.Playback.PlaybackRegistryTest do
  use ExUnit.Case, async: true

  alias Spoti.Playback.PlaybackRegistry
  alias Spoti.Playback.PlaybackServer

  @playlist_id 123
  
  describe "start_link/1" do
    test "returns pid" do
      {:ok, pid} = PlaybackRegistry.start_link
      assert is_pid(pid)
    end
  end

  describe "get_playback/1" do
    setup do
      {:ok, _} = PlaybackRegistry.start_link()
      {:ok, []}
    end

    test "returns pid if playback id found" do
      {:ok, _} = PlaybackRegistry.start_playback(@playlist_id)
      pid = PlaybackRegistry.get_playback(@playlist_id)
      assert is_pid(pid)
      assert PlaybackServer.get_state(pid) == %PlaybackServer{playlist_id: @playlist_id}
    end

    test "returns nil if not found" do
      assert PlaybackRegistry.get_playback(@playlist_id) == nil
    end
  end

  describe "start_playback/1" do
    test "starts playback for playlist id" do
      {:ok, _} = PlaybackRegistry.start_link()
      {:ok, pid} = PlaybackRegistry.start_playback(@playlist_id)
      assert is_pid(pid)
      assert PlaybackServer.get_state(pid) == %PlaybackServer{playlist_id: @playlist_id}
    end
  end
end
