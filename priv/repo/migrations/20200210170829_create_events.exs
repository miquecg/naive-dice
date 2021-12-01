defmodule NaiveDice.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table("events") do
      add :title, :varchar, null: false
      add :allocation, :integer, null: false

      timestamps()
    end

    create constraint("events",
      :allocation_non_negative,
      check: "allocation >= 0"
    )
  end
end
