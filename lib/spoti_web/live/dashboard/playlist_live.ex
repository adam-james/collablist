defmodule SpotiWeb.Dashboard.PlaylistLive do
  use Phoenix.LiveView

  alias SpotiWeb.Presence
  alias Spoti.Playlists
  alias Spoti.Playback

  def render(assigns) do
    Phoenix.View.render(SpotiWeb.Dashboard.PlaylistView, "show.html", assigns)
  end

  def mount(%{profile: profile, playlist: playlist}, socket) do
    {:ok, playback} = Playback.ensure_playback_started(playlist.id)

    # Track user presence.
    Presence.track(
      self(),
      topic(playlist),
      profile.id,
      %{
        display_name: profile.display_name,
        id: profile.id
      }
    )

    # Subscribe to topic for updates from other live views.
    SpotiWeb.Endpoint.subscribe(topic(playlist))

    users = get_present_users(playlist)

    socket =
      socket
      |> assign(:search_results, [])
      |> assign(:profile, profile)
      |> assign(:playlist, playlist)
      |> assign(:users, users)
      |> assign(:playback, playback)

    {:ok, socket}
  end

  def handle_event("play", _params, socket) do
    {:ok, _} = Playback.play(socket.assigns.playlist.id)
    {:noreply, socket}
  end

  def handle_event("pause", _params, socket) do
    {:ok, _} = Playback.pause(socket.assigns.playlist.id)
    {:noreply, socket}
  end

  def handle_event("search", %{"value" => value}, socket) do
    if String.length(value) < 1 do
      {:noreply, update(socket, :search_results, fn _ -> [] end)}
    else
      # TODO clean this up.
      # Can you keep this elsewhere? Not query every time?
      {:ok, %{items: items}} =
        Spotify.Search.query(
          Spoti.Auth.get_credentials!(socket.assigns.profile),
          q: value,
          type: "track"
        )

      {:noreply, update(socket, :search_results, fn _ -> items end)}
    end
  end

  def handle_event("add_track", %{"spotify_id" => spotify_id}, socket) do
    playlist = socket.assigns.playlist
    profile = socket.assigns.profile

    {:ok, _} =
      Playlists.create_track(%{
        spotify_id: spotify_id,
        playlist_id: playlist.id,
        added_by_id: socket.assigns.profile.id
      })

    {:ok, track} =
      Spotify.Track.get_track(
        Spoti.Auth.get_credentials!(profile),
        spotify_id
      )

    {:ok, _} = Playback.add_track(playlist.id, track)

    {:noreply, assign(socket, :search_results, [])}
  end

  # Handle playback state updates.
  def handle_info(%{event: "updated_playback", payload: playback}, socket) do
    {:noreply, assign(socket, playback: playback)}
  end

  # Handle presence diffs.
  def handle_info(%{event: "presence_diff"}, socket = %{assigns: %{playlist: playlist}}) do
    users = get_present_users(playlist)
    {:noreply, assign(socket, users: users)}
  end

  defp get_present_users(playlist) do
    Presence.list(topic(playlist))
    |> Enum.map(fn {_user_id, data} ->
      data[:metas]
      |> List.first()
    end)
  end

  defp topic(playlist) do
    "playlist:#{playlist.id}"
  end

  defp get_creds!(profile) do
    Spoti.Auth.get_credentials!(profile)
  end
end
