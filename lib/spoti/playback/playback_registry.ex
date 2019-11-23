defmodule Spoti.Playback.PlaybackRegistry do
  use GenServer

  alias Spoti.Playback.PlaybackServer

  # Client

  def start_link(_args) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def start_playback(playlist_id) do
    GenServer.call(__MODULE__, {:start_playback, playlist_id})
  end

  def get_playback(playlist_id) do
    GenServer.call(__MODULE__, {:get_playback, playlist_id})
  end

  # Server

  def init(map) do
    {:ok, map}
  end

  def handle_call({:start_playback, playlist_id}, _from, map) do
    {:ok, pid} = PlaybackServer.start_link(playlist_id)
    {:reply, {:ok, pid}, Map.put(map, playlist_id, pid)}
  end

  def handle_call({:get_playback, playlist_id}, _from, map) do
    {:reply, Map.get(map, playlist_id), map}
  end
end
