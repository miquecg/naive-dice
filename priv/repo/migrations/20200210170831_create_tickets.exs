defmodule NaiveDice.Repo.Migrations.CreateTickets do
  use Ecto.Migration

  def change do
    # TODO: the table definition is far from being complete
    create table(:tickets) do
      add :user_name, :string
      # TODO: add event_id?

      timestamps()
    end

    # TODO: do we need indicies for "tickets" table?
  end
end
