defmodule Reservation.Schemas.Ticket do
  @moduledoc """
  A purchased ticket
  """

  use Ecto.Schema

  alias Reservation.Schemas.Event

  schema "tickets" do
    field :order_id, Ecto.UUID
    field :user_name, :string

    belongs_to :event, Event

    timestamps()
  end
end
