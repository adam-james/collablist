defmodule SpotiWeb.CounterLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    <p>Count: <%= @count %></p>
    <button phx-click="dec">-</button>
    <button phx-click="inc">+</button>
    """
  end

  def mount(session, socket) do
    {:ok, assign(socket, :count, session[:count] || 0)}
  end

  def handle_event("inc", _, socket) do
    {:noreply, update(socket, :count, &(&1 + 1))}
  end

  def handle_event("dec", _, socket) do
    {:noreply, update(socket, :count, &(&1 - 1))}
  end
end
