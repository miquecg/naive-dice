defmodule Reservation.Schemas.Ticket do
  @moduledoc """
  A purchased ticket
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias Reservation.Schemas.{Event, Order}

  schema "tickets" do
    field :order_id, Ecto.UUID
    field :user_name, :string

    belongs_to :event, Event

    timestamps()
  end

  def changeset(%Order{status: :checkout_completed} = order) do
    %__MODULE__{}
    |> change(Map.take(order, [:order_id, :user_name, :event_id]))
    |> assoc_constraint(:event)
  end
end
