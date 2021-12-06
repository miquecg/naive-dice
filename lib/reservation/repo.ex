defmodule Reservation.Repo do
  use Ecto.Repo,
    otp_app: :naive_dice,
    adapter: Ecto.Adapters.Postgres

  import Ecto.Query

  alias Reservation.Schemas.{Event, Order, Ticket}

  def allocate_ticket(%Order{} = order) do
    order
    |> Ticket.changeset()
    |> insert()
  end

  def cancel_order(%Order{} = order, reason) do
    order
    |> Order.cancel(reason)
    |> insert()
  end

  def close_order(%Order{} = order) do
    order
    |> Order.close()
    |> insert()
  end

  @doc """
  Allocation - Sold tickets
  """
  def count_tickets_left do
    Event
    |> join(:left, [e], t in Ticket, on: e.id == t.event_id)
    |> group_by([e], e.id)
    |> select([e, t], {e.id, e.allocation - count(t.id)})
    |> all()
    |> Enum.reduce(%{}, fn {id, ticket_count}, acc ->
      Map.put(acc, id, ticket_count)
    end)
  end

  def ticket_purchased?(%Order{} = order) do
    clauses = [user_name: order.user_name, event_id: order.event_id]

    case get_by(Ticket, clauses) do
      # Just to be strict here about boolean return
      nil ->
        false

      _ticket ->
        true
    end
  end

  def update_progress(%Order{} = order, status) do
    order
    |> Order.progress(status)
    |> insert()
  end
end
