defmodule NaiveDice.Repo.Migrations.CreateOrders do
  use Ecto.Migration

  def change do
    create table("orders") do
      add :order_id, :uuid, null: false
      # It could be an enum column but they
      # can be tricky to change afterwards.
      add :status, :varchar, null: false
      add :user_name, :varchar, null: false
      add :price_cents, :integer, null: false

      # To be measured the impact on write
      # performance if it was the case.
      # Data can be denormalized because
      # there are other checks in place.
      add :event_id, references("events"), null: false

      timestamps(type: :utc_datetime_usec)
    end
  end
end
