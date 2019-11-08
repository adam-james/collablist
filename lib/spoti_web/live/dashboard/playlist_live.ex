defmodule SpotiWeb.Dashboard.PlaylistLive do
  use Phoenix.LiveView

  alias Spoti.Playlists

  def render(assigns) do
    Phoenix.View.render(SpotiWeb.Dashboard.PlaylistView, "show.html", assigns)
  end

  def mount(session, socket) do
    SpotiWeb.Endpoint.subscribe(topic(session[:playlist]))
    socket =
      socket
      |> assign(:search_results, [])
      |> assign(:profile, session[:profile])
      |> assign(:playlist, session[:playlist])
      |> assign(:tracks, session[:tracks])

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
    {:ok, track} =
      Playlists.create_track(%{
        spotify_id: spotify_id,
        playlist_id: playlist.id,
        added_by_id: socket.assigns.profile.id
      })

    # TODO just load the last track
    {:ok, tracks} =
      Playlists.get_spotify_tracks(Spoti.Auth.get_credentials!(socket.assigns.profile), playlist)

    # TODO just send the new track
    SpotiWeb.Endpoint.broadcast_from(self(), topic(playlist), "new_track", %{tracks: tracks})

    socket =
      socket
      |> update(:search_results, fn _ -> [] end)
      |> update(:tracks, fn _ -> tracks end)

    {:noreply, socket}
  end

  def handle_info(%{event: "new_track", payload: %{tracks: tracks}}, socket) do
    {:noreply, update(socket, :tracks, fn _ -> tracks end)}
  end

  defp topic(playlist) do
    "playlist:#{playlist.id}"
  end
end
