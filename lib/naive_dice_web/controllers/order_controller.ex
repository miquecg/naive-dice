defmodule NaiveDiceWeb.OrderController do
  use NaiveDiceWeb, :controller

  require Logger

  action_fallback(NaiveDiceWeb.FallbackController)

  plug :normalize when action in [:create]

  @doc """
  STEP 1: Renders an empty form with user name input
  """
  def new(conn, %{"event_id" => event_id}) do
    with {:ok, event} <- Reservation.event_info(event_id, [:title, :remaining_tickets]) do
      conn
      |> maybe_show_error(event)
      |> render("new.html", %{event: event})
    end
  end

  @doc """
  STEP 2: Renders the Stripe payment form
  """
  def edit(conn, %{"id" => _order_id}) do
    render(conn, "edit.html")
  end

  @doc """
  STEP 3: Renders the confirmation / receipt / thank you screen
  """
  def show(conn, %{"id" => ticket_id}) do
    # TODO: don't render a pending ticket as a successfully purchased one
    with {:ok, ticket} <- Reservation.get_ticket(ticket_id) do
      render(conn, "show.html", %{ticket: ticket})
    end
  end

  # TRANSITIONS BETWEEN WIZARD STEPS

  @doc """
  Books a ticket for 5 minutes
  """
  def create(conn, %{"event_id" => event_id}) do
    user_name = conn.assigns[:user_name]

    with {:ok, booking_id} <- Reservation.book_event(event_id, user_name) do
      token = Phoenix.Token.sign(NaiveDiceWeb.Endpoint, "ticket booking", booking_id)
      redirect(conn, to: Routes.order_path(conn, :edit, token))
    end
  end

  @doc """
  Updates a ticket with the charge details and redirects to the confirmation / receipt / thank you
  """
  def update(conn, %{"id" => _order_id}) do
    # TODO: implement
    redirect(conn, to: Routes.order_path(conn, :show, "asdf"))
  end

  defp normalize(conn, _opts) do
    conn.params["order"]["user_name"]
    |> String.split()
    |> Enum.join(" ")
    |> String.normalize(:nfc)
    |> then(&assign(conn, :user_name, &1))
  end

  defp maybe_show_error(conn, %{remaining_tickets: 0}) do
    # Erases previous form errors but it doesn't matter.
    put_flash(conn, :error, "Sorry, no tickets left")
  end

  defp maybe_show_error(conn, _), do: conn
end
