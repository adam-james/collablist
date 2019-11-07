defmodule SpotiWeb.Dashboard.SearchLive do
  use Phoenix.LiveView

  def render(assigns) do
    Phoenix.View.render(SpotiWeb.Dashboard.SearchView, "index.html", assigns)
  end

  def mount(session, socket) do
    socket =
      socket
      |> assign(:items, session[:items] || [])
      |> assign(:profile, session[:profile])

    {:ok, socket}
  end

  def handle_event("search", %{"value" => value}, socket) do
    # TODO clean this up.
    # Can you keep this elsewhere? Not query every time?
    if String.length(value) < 1 do
      {:noreply, update(socket, :items, fn _ -> [] end)}
    else
      {:ok, %{items: items}} =
      Spotify.Search.query(
        Spoti.Auth.get_credentials!(socket.assigns.profile),
        q: value,
        type: "track"
      )

      {:noreply, update(socket, :items, fn _ -> items end)}
    end
  end
end
