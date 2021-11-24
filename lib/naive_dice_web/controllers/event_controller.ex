defmodule NaiveDiceWeb.EventController do
  use NaiveDiceWeb, :controller

  alias NaiveDice.Events
  def index(conn, _params) do
    events = Events.list_all()

    render(conn, "index.html", %{events: events})
  end

  def show(conn, %{"id" => id}) do
    with {:ok, event} <- Events.get_event_by_id(id) do
      render(conn, "show.html", %{event: event})
    end
  end
end
