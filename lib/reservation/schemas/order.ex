defmodule Reservation.Schemas.Order do
  @moduledoc """
  An order placed on the reservation system.
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias __MODULE__
  alias Reservation.Schemas.Event

  @cancel_status [
    :booking_expired,
    :canceled_already_purchased,
    :canceled_no_tickets,
    :checkout_create_failed,
    :checkout_expired
  ]
  @progress_status [
    :booking_requested,
    :checkout_created,
    :ticket_booked
  ]
  @final_status :checkout_completed

  schema "orders" do
    field :order_id, Ecto.UUID

    field :status,
          Ecto.Enum,
          values: @cancel_status ++ @progress_status ++ [@final_status]

    field :user_name, :string
    field :price_cents, :integer

    belongs_to :event, Event

    timestamps(type: :utc_datetime_usec)
  end

  @fields [:user_name, :price_cents, :event_id]

  def new(%{} = params) do
    %__MODULE__{
      order_id: Ecto.UUID.generate()
    }
    |> cast(params, @fields)
    |> validate()
    |> apply_action(:update)
  end

  def cancel(order, :no_tickets), do: cancel(order, :canceled_no_tickets)

  def cancel(order, :already_purchased) do
    cancel(order, :canceled_already_purchased)
  end

  def cancel(%Order{} = order, status) when status in @cancel_status do
    change_status(order, status)
  end

  def close(%Order{} = order) do
    change_status(order, @final_status)
  end

  def progress(%Order{} = order, status) when status in @progress_status do
    change_status(order, status)
  end

  defp validate(changeset) do
    changeset
    |> validate_required([:order_id | @fields])
    |> validate_length(:user_name, min: 3, max: 20)
    |> validate_number(:price_cents, greater_than_or_equal_to: 0)
  end

  defp change_status(order, status) do
    order
    |> Map.take([:order_id | @fields])
    |> Map.put(:status, status)
    |> then(&struct(__MODULE__, &1))
  end
end
