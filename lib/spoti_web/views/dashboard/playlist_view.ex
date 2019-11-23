defmodule SpotiWeb.Dashboard.PlaylistView do
  use SpotiWeb, :view

  def millis_to_minutes(millis) do
    total_seconds = div(millis, 1000)
    minutes = div(total_seconds, 60)
    seconds = rem(total_seconds, 60)
    seconds_string = to_string(seconds)
    final_seconds =
      if String.length(seconds_string) == 1 do
        "0" <> seconds_string
      else
        seconds_string
      end
    to_string(minutes) <> ":" <> final_seconds
  end
end
