defmodule Reservation.Repo do
  use Ecto.Repo,
    otp_app: :naive_dice,
    adapter: Ecto.Adapters.Postgres

  alias Reservation.Schemas.{Order, Ticket}

  def cancel_order(%Order{} = order, reason) do
    order
    |> Order.cancel(reason)
    |> insert()
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
