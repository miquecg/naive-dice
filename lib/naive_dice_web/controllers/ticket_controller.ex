defmodule NaiveDiceWeb.TicketController do
  use NaiveDiceWeb, :controller
  alias NaiveDice.Events

  action_fallback(NaiveDiceWeb.FallbackController)

  # STEPS OF THE WIZARD

  @doc """
  STEP 1: Renders an empty form with user name input
  That's an entry point for the booking flow.
  """
  def new(conn, %{"event_id" => event_id}) do
    with {:ok, event} <- Events.get_event_by_id(event_id) do
      # TODO: implement this
      remaining_tickets = 5

      # see https://hexdocs.pm/phoenix_html/Phoenix.HTML.Form.html
      render(conn, "new.html", %{
        changeset: Events.new_ticket_changeset(),
        event: event,
        remaining_tickets: remaining_tickets
      })
    end
  end

  @doc """
  STEP 2: Renders the Stripe payment form
  """
  def edit(conn, %{"id" => ticket_id}) do
    # TODO: implement this
    with {:ok, ticket} <- Events.get_ticket_by_id(ticket_id) do
      render(conn, "edit.html", %{ticket: ticket})
    end
  end

  @doc """
  STEP 3: Renders the confirmation / receipt / thank you screen
  """
  def show(conn, %{"id" => ticket_id}) do
    # TODO: don't render a pending ticket as a successfully purchased one
    with {:ok, ticket} <- Events.get_ticket_by_id(ticket_id) do
      render(conn, "show.html", %{ticket: ticket})
    end
  end

  # TRANSITIONS BETWEEN WIZARD STEPS

  @doc """
  Reserves a ticket for 5 minutes
  """
  def create(conn, %{"event_id" => event_id, "ticket" => %{"user_name" => user_name}}) do
    with {:ok, event} <- Events.get_event_by_id(event_id) do
      # TODO: implement reservation "the right way" - handle all edge cases!!!
      {:ok, ticket} = Events.reserve_ticket(event, user_name)

      # TODO: I think a Ticket can represent both a pending reservation and a purchased ticket
      # but you may have a different opinion :-)
      conn |> redirect(to: Routes.ticket_path(conn, :edit, ticket.id))
    end
  end

  @doc """
  Updates a ticket with the charge details and redirects to the confirmation / receipt / thank you
  """
  def update(conn, %{"id" => ticket_id}) do
    # TODO: implement this
    conn |> redirect(to: Routes.ticket_path(conn, :show, ticket_id))
  end

  # ADMIN ACTIONS

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
