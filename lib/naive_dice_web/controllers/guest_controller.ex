defmodule NaiveDiceWeb.GuestController do
  use NaiveDiceWeb, :controller

  @doc """
  Lists all the guests in the system, across all events (we have just 1 event in seeds.exs)
  Since we only sell 1 ticket per person, just render the list of tickets
  """
  def index(conn, _params) do
    guest_names = [
      "John Doe",
      "Alice Brown",
      "Ben Smith"
    ]

    render(conn, "index.html", %{guest_names: guest_names})
  end

  @doc """
  Helper method which returns the system into the original state (useful for testing)
  """
  def reset_guests(conn, _params) do
    # TODO: delete all tickets here.

    conn
    |> put_flash(:info, "All tickets deleted. Starting from scratch.")
    |> redirect(to: "/")
  end
end
