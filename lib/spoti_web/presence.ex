defmodule SpotiWeb.Presence do
  use Phoenix.Presence,
    otp_app: :spoti,
    pubsub_server: Spoti.PubSub
end
