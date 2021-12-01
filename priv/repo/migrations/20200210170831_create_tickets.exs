defmodule NaiveDice.Repo.Migrations.CreateTickets do
  use Ecto.Migration

  def change do
    create table("tickets") do
      add :order_id, :uuid, null: false
      add :user_name, :varchar, null: false
      # It would make sense to have it.
      # add :ticket_number, :integer, null: false
      add :price_cents, :integer, null: false

      add :event_id, references("events"), null: false

      timestamps()
    end

    # We are assuming one order per ticket purchased.
    unique_index("tickets", [:order_id])
  end
end
