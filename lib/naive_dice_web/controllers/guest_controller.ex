defmodule NaiveDiceWeb.GuestController do
  use NaiveDiceWeb, :controller

  def index(conn, _params) do
    # We only sell one event and one ticket per person.
    tickets = Reservation.all_tickets_info([:user_name])
    render(conn, "index.html", %{tickets: tickets})
  end

  def reset_guests(conn, _params) do
    :ok = Reservation.reset()

    conn
    |> put_flash(:info, "All orders and tickets deleted. Starting from scratch.")
    |> redirect(to: "/")
  end
end
