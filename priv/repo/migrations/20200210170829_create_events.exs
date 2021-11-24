defmodule NaiveDice.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :title, :string
      add :allocation, :integer, null: false

      timestamps()
    end
  end
end
