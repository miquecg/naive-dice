defmodule Reservation.EventBookerSupervisor do
  @moduledoc false

  use Supervisor

  def start_link(_init_arg) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init([]) do
    children = [
      {DynamicSupervisor, strategy: :one_for_one, name: Reservation.OrderSupervisor},
      Reservation.EventBooker
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
