defmodule Spoti.Repo do
  use Ecto.Repo,
    otp_app: :spoti,
    adapter: Ecto.Adapters.Postgres
end
