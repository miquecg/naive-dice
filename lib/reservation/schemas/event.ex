defmodule Reservation.Schemas.Event do
  use Ecto.Schema

  schema "events" do
    field :title
    field :allocation, :integer

    timestamps()
  end
end
