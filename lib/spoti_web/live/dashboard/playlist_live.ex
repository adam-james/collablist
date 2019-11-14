defmodule SpotiWeb.Dashboard.PlaylistLive do
  use Phoenix.LiveView

  alias SpotiWeb.Presence
  alias Spoti.Playlists

  def render(assigns) do
    Phoenix.View.render(SpotiWeb.Dashboard.PlaylistView, "show.html", assigns)
  end

  def mount(%{profile: profile, playlist: playlist}, socket) do
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
    {:ok, tracks} = get_tracks(profile, playlist)

    socket =
      socket
      |> assign(:search_results, [])
      |> assign(:profile, profile)
      |> assign(:playlist, playlist)
      |> assign(:tracks, tracks)
      |> assign(:users, users)

    {:ok, socket}
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

    {:ok, _track} =
      Playlists.create_track(%{
        spotify_id: spotify_id,
        playlist_id: playlist.id,
        added_by_id: socket.assigns.profile.id
      })

    # TODO just load the last track
    {:ok, tracks} = get_tracks(profile, playlist)

    # TODO just send the new track
    SpotiWeb.Endpoint.broadcast_from(self(), topic(playlist), "new_track", %{tracks: tracks})

    socket =
      socket
      |> update(:search_results, fn _ -> [] end)
      |> update(:tracks, fn _ -> tracks end)

    {:noreply, socket}
  end

  # Handle messages from other live views.
  def handle_info(%{event: "new_track", payload: %{tracks: tracks}}, socket) do
    {:noreply, update(socket, :tracks, fn _ -> tracks end)}
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

  defp get_tracks(profile, playlist) do
    Playlists.get_spotify_tracks(
      Spoti.Auth.get_credentials!(profile),
      playlist
    )
  end
end
