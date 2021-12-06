defmodule Reservation.EventBooker do
  @moduledoc """
  Manages available tickets and purchase orders.
  """

  use GenServer

  require Logger

  alias Reservation.{Order, OrderSupervisor}
  alias Reservation.Repo

  def start_link(opts) do
    opts = Keyword.put_new(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, [], opts)
  end

  def process(order) do
    booking_id = generate_id()
    GenServer.call(__MODULE__, {:process, {order, booking_id}})
  end

  def remaining_tickets(event_id) do
    GenServer.call(__MODULE__, {:remaining_tickets, event_id})
  end

  defp generate_id do
    random_bytes = :crypto.strong_rand_bytes(16)
    Base.hex_encode32(random_bytes, padding: false)
  end

  ## Callbacks

  @impl GenServer
  def init([]), do: {:ok, nil, {:continue, :fetch}}

  defguardp not_found(state, event_id) when not is_map_key(state, event_id)

  @impl GenServer
  def handle_call({:process, {order, _}}, _from, state)
      when not_found(state, order.event_id) do
    reply_not_found(state)
  end

  @impl GenServer
  def handle_call({:process, {order, booking_id}}, _from, state) do
    case decrement_one_ticket(state, order) do
      {:no_tickets, state} ->
        {:ok, order} = Repo.cancel_order(order, :no_tickets)
        Logger.info("Order #{order.order_id} canceled. No tickets for event #{order.event_id}")
        reply_no_tickets(state)

      {_, state} ->
        name = Order.name(booking_id)
        _ = start_booking(order: order, name: name)
        reply_ok(booking_id, state)
    end
  end

  @impl GenServer
  def handle_call({:remaining_tickets, event_id}, _from, state)
      when not_found(state, event_id) do
    reply_not_found(state)
  end

  @impl GenServer
  def handle_call({:remaining_tickets, event_id}, _from, state) do
    remaining = Map.get(state, event_id)
    reply_ok(remaining, state)
  end

  @impl GenServer
  def handle_continue(:fetch, nil) do
    {:noreply, Repo.count_tickets_left()}
  end

  @impl GenServer
  def handle_info({:DOWN, _ref, :process, _pid, :normal}, state) do
    no_reply(state)
  end

  @impl GenServer
  def handle_info({:DOWN, _ref, :process, _pid, {:canceled, order}}, state) do
    {_, state} = increment_one_ticket(state, order)
    no_reply(state)
  end

  defp start_booking(opts) do
    {:ok, pid} = DynamicSupervisor.start_child(OrderSupervisor, {Order, opts})
    Process.monitor(pid)
    :ok
  end

  defp decrement_one_ticket(state, order) do
    Map.get_and_update(state, order.event_id, fn
      0 ->
        {:no_tickets, 0}

      current when current > 0 ->
        {current, current - 1}

      _ ->
        # Maybe this is a bit too defensive.
        Logger.error("Negative number of tickets for event #{order.event_id}")
        {:no_tickets, 0}
    end)
  end

  defp increment_one_ticket(state, order) do
    # We could add a check here to detect overbooking
    Map.get_and_update(state, order.event_id, fn
      current ->
        {current, current + 1}
    end)
  end

  defp no_reply(state), do: {:noreply, state}

  defp reply_no_tickets(state), do: {:reply, {:error, :no_tickets}, state}
  defp reply_not_found(state), do: {:reply, {:error, :event_not_found}, state}
  defp reply_ok(value, state), do: {:reply, {:ok, value}, state}
end
