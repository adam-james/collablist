defmodule Spoti.Playback do
  alias Spoti.Playback.PlaybackRegistry
  alias Spoti.Playback.PlaybackServer

  def ensure_playback_started(playlist_id), do: get_playback(playlist_id)

  def play(playlist_id) do
    playlist_id |> find_playback() |> do_play()
  end

  def pause(playlist_id) do
    playlist_id |> find_playback() |> do_pause()
  end

  def add_track(playlist_id, track) do
    playlist_id |> find_playback() |> do_add_track(track)
  end

  # Private

  defp do_play({:error, reason}), do: {:error, reason}
  defp do_play({:ok, pid}), do: PlaybackServer.play(pid)

  defp do_pause({:error, reason}), do: {:error, reason}
  defp do_pause({:ok, pid}), do: PlaybackServer.pause(pid)

  defp do_add_track({:error, reason}, _track), do: {:error, reason}
  defp do_add_track({:ok, pid}, track), do: {:ok, PlaybackServer.add_track(pid, track)}

  defp find_playback(playlist_id) do
    case PlaybackRegistry.get_playback(playlist_id) do
      nil -> {:error, "Playback not found."}
      pid -> {:ok, pid}
    end
  end

  defp get_playback(playlist_id) do
    playlist_id
    |> get_playback_pid()
    |> get_or_start_playback()
  end

  defp get_playback_pid(playlist_id) do
    case PlaybackRegistry.get_playback(playlist_id) do
      nil -> PlaybackRegistry.start_playback(playlist_id)
      pid -> {:ok, pid}
    end
  end

  defp get_or_start_playback({:error, reason}), do: {:error, reason}
  defp get_or_start_playback({:ok, pid}), do: {:ok, PlaybackServer.get_state(pid)}
end
