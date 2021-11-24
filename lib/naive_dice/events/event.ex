defmodule NaiveDice.Events.Event do
  use Ecto.Schema

  schema "events" do
    field :allocation, :integer
    field :title

    timestamps()
  end
end
