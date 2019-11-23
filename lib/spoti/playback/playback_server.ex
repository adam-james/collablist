defmodule Spoti.Playback.PlaybackServer do
  use GenServer

  alias Spoti.Playback.PlaybackServer

  defstruct playlist_id: -1,
            current_track: %Spotify.Track{},
            progress_ms: 0,
            is_playing: false,
            timer_ref: nil

  # Client

  def start_link(playlist_id) do
    GenServer.start_link(__MODULE__, playlist_id)
  end

  def get_state(pid) do
    GenServer.call(pid, :get_state)
  end

  def play(pid) do
    GenServer.call(pid, :play)
  end

  def pause(pid) do
    GenServer.call(pid, :pause)
  end

  # Server

  def init(playlist_id) do
    state = %PlaybackServer{playlist_id: playlist_id}
    {:ok, state}
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  def handle_call(:play, _from, state) do
    # TODO handle multiple subsequent play clicks
    # Currently it sets more than one timer, speeding up the tick
    timer_ref = Process.send_after(self(), :tick, 1000)
    next_state = %{state | is_playing: true, timer_ref: timer_ref}
    broadcast(next_state)
    {:reply, next_state, next_state}
  end

  def handle_call(:pause, _from, state) do
    Process.cancel_timer(state.timer_ref)
    next_state = %{state | is_playing: false, timer_ref: nil}
    broadcast(next_state)
    {:reply, next_state, next_state}
  end

  def handle_info(:tick, state) do
    timer_ref = Process.send_after(self(), :tick, 1000)
    next_state = %{state | progress_ms: state.progress_ms + 1000, timer_ref: timer_ref}
    broadcast(next_state)
    {:noreply, next_state}
  end

  # TODO broadcast play, pause, and tick
  defp broadcast(state) do
    SpotiWeb.Endpoint.broadcast!(topic(state), "updated_playback", state)
  end

  defp topic(state) do
    "playlist:#{state.playlist_id}"
  end
end
