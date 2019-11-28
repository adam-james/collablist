defmodule Spoti.Playback.PlaybackServer do
  use GenServer

  alias Spoti.Playback.PlaybackServer
  alias Spoti.Playlists
  alias Spoti.Profiles

  defstruct playlist_id: -1,
            current_track: nil,
            upcoming_tracks: [],
            played_tracks: [],
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

  def add_track(pid, track) do
    GenServer.call(pid, {:add_track, track})
  end

  # Server

  def init(playlist_id) do
    {:ok, tracks} = get_tracks(playlist_id)

    state = %PlaybackServer{
      current_track: initial_current_track(tracks),
      playlist_id: playlist_id,
      upcoming_tracks: initial_upcoming_tracks(tracks)
    }

    {:ok, state}
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:add_track, track}, _from, state) do
    next_state =
      if state.current_track == nil do
        %{state | current_track: track}
      else
        %{state | upcoming_tracks: state.upcoming_tracks ++ [track]}
      end

    broadcast(next_state)
    {:reply, next_state, next_state}
  end

  def handle_call(:play, _from, state) do
    case handle_play(state) do
      {:error, reason} ->
        {:reply, {:error, reason}, state}
      {:ok, next_state} ->
        {:reply, {:ok, next_state}, next_state}
    end
  end

  def handle_call(:pause, _from, state) do
    state.playlist_id
    |> get_playlist_creds()
    |> Spotify.Player.pause()
    |> build_resp_pause(state)
  end

  defp build_resp_pause({:error, reason}, state) do
    {:reply, {:error, reason}, state}
  end

  defp build_resp_pause(:ok, state) do
    if state.timer_ref != nil do
      Process.cancel_timer(state.timer_ref)
    end

    next_state = %{state | is_playing: false, timer_ref: nil}
    broadcast(next_state)
    {:reply, {:ok, next_state}, next_state}
  end

  def handle_info(:tick, state) do
    progress_ms = state.progress_ms + 1000

    if progress_ms > state.current_track.duration_ms do
      upcoming_tracks =
        case state.upcoming_tracks do
          [] -> []
          [_ | upcoming_tracks] -> upcoming_tracks
        end

      current_track = List.first(state.upcoming_tracks)
      played_tracks = [state.current_track | state.played_tracks]

      next_state = %{
        state
        | current_track: current_track,
          played_tracks: played_tracks,
          upcoming_tracks: upcoming_tracks,
          is_playing: false,
          timer_ref: nil,
          progress_ms: 0
      }

      broadcast(next_state)
      send(self(), :play_next)
      {:noreply, next_state}
    else
      timer_ref = Process.send_after(self(), :tick, 1000)
      next_state = %{state | progress_ms: progress_ms, timer_ref: timer_ref}
      broadcast(next_state)
      {:noreply, next_state}
    end
  end

  def handle_info(:play_next, state) do
    {:ok, next_state} = handle_play(state)
    {:noreply, next_state}
  end

  defp broadcast(state) do
    SpotiWeb.Endpoint.broadcast!(topic(state), "updated_playback", state)
  end

  defp topic(state) do
    "playlist:#{state.playlist_id}"
  end

  defp get_tracks(creds, playlist) do
    Playlists.get_spotify_tracks(creds, playlist)
  end

  defp get_tracks(playlist_id) do
    playlist = get_playlist(playlist_id)

    playlist
    |> get_playlist_profile()
    |> get_profile_creds()
    |> get_tracks(playlist)
  end

  defp get_playlist(playlist_id) do
    Playlists.get_playlist!(playlist_id)
  end

  defp get_playlist_profile(playlist) do
    Profiles.get_profile!(playlist.profile_id)
  end

  defp get_profile_creds(profile) do
    Spoti.Auth.get_credentials!(profile)
  end

  defp get_playlist_creds(playlist_id) do
    playlist_id
    |> get_playlist()
    |> get_playlist_profile()
    |> get_profile_creds()
  end

  defp initial_current_track(initial_tracks) do
    List.first(initial_tracks)
  end

  defp initial_upcoming_tracks(initial_tracks) do
    if length(initial_tracks) > 0 do
      [_ | upcoming_tracks] = initial_tracks
      upcoming_tracks
    else
      []
    end
  end

  defp handle_play(state) do
    cond do
      state.is_playing -> {:error, "Already playing."}
      state.current_track == nil -> {:error, "No track to play."}
      true -> do_play(state)
    end
  end

  defp do_play(state) do
    state
    |> build_play_req()
    |> request_play(state.playlist_id)
    |> handle_play_resp(state)
  end

  defp build_play_req(state) do
    %{"uris" => [state.current_track.uri], "position_ms" => state.progress_ms}
    |> Jason.encode!()
  end

  defp request_play(body, playlist_id) do
    get_playlist_creds(playlist_id)
    |> Spotify.Player.play(body)
  end

  defp handle_play_resp({:error, reason}, _state), do: {:error, reason}
  defp handle_play_resp(:ok, state) do
    timer_ref = Process.send_after(self(), :tick, 1000)
    next_state = %{state | is_playing: true, timer_ref: timer_ref}
    broadcast(next_state)
    {:ok, next_state}
  end
end
