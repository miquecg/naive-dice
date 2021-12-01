defmodule NaiveDice.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Reservation.Repo,
      {Registry, keys: :unique, name: Registry.Orders},
      Reservation.EventBookerSupervisor,
      {Phoenix.PubSub, [name: NaiveDice.PubSub, adapter: Phoenix.PubSub.PG2]},
      NaiveDiceWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: NaiveDice.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    NaiveDiceWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
