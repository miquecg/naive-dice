defmodule NaiveDiceWeb.EventController do
  use NaiveDiceWeb, :controller

  def index(conn, _params) do
    events = Reservation.all_events_info([:title])

    render(conn, "index.html", %{events: events})
  end
end
