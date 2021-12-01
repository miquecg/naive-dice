# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     NaiveDice.Repo.insert!(%NaiveDice.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

Reservation.Repo.insert!(%Reservation.Schemas.Event{title: "THE BEST EVER SHOW", allocation: 5})
