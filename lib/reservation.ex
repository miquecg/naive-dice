defmodule Reservation do
  @moduledoc """
  Entrypoint to the reservation system.
  """

  alias Reservation.EctoHelpers
  alias Reservation.EventBooker
  alias Reservation.Payment
  alias Reservation.Payment.CheckoutSession
  alias Reservation.Repo
  alias Reservation.Schemas.{Event, Order, Ticket}

  def all_events_info(keys) do
    events = Repo.all(Event)
    Enum.map(events, &build_info(&1, keys))
  end

  def all_tickets_info(keys) do
    tickets = Repo.all(Ticket)
    Enum.map(tickets, &build_info(&1, keys))
  end

  def event_info(event_id, keys) do
    # It could be good to optimise this a little
    # and query only the GenServer when possible.
    case Repo.get(Event, event_id) do
      nil ->
        {:error, :event_not_found}

      event ->
        {:ok, build_info(event, keys)}
    end
  end

  def book_event(event_id, user_name) do
    # For the sake of simplicity assume
    # there is a Pricing.Service somewhere.
    params = %{
      event_id: event_id,
      user_name: user_name,
      price_cents: Pricing.Service.current(event_id)
    }

    case create_order(params) do
      {:ok, order} -> EventBooker.process(order)
      {:error, _} = error -> error
    end
  end

  @ten_seconds_timeout 10_000
  def create_checkout(provider, booking_id, extra \\ []) do
    request = {:create_checkout, provider, extra}

    case Reservation.Order.call(booking_id, request, @ten_seconds_timeout) do
      {:ok, %CheckoutSession{url: url}} ->
        {:ok, url}

      {:error, _} = error ->
        error
    end
  end

  def notify(provider, {:payment_received, session_id}, returning \\ []) do
    case Payment.Client.retrieve_checkout(provider, session_id) do
      {:ok, %CheckoutSession{payment_status: :paid} = session} ->
        {:ok, order} = Reservation.Order.call(session.booking_id, :payment_received)
        {:ok, _} = Repo.allocate_ticket(order)
        {:ok, build_info(order, returning)}

      {:error, _} = error ->
        error
    end
  end

  @doc """
  Exposed for testing.
  """
  def reset do
    {_, nil} = Repo.delete_all(Order)
    {_, nil} = Repo.delete_all(Ticket)
    Supervisor.stop(Reservation.EventBookerSupervisor, :kill)
  end

  defp build_info(schema, keys) do
    Enum.reduce(keys, %{}, &build_info(schema, &1, &2))
  end

  defp build_info(%Event{id: event_id}, :remaining_tickets = key, acc) do
    # Event must exist on EventBooker if it exists on database.
    {:ok, remaining} = EventBooker.remaining_tickets(event_id)
    Map.put(acc, key, remaining)
  end

  defp build_info(schema, key, acc) when is_map_key(schema, key) do
    Map.put(acc, key, Map.get(schema, key))
  end

  defp build_info(_, _, acc), do: acc

  defp create_order(params) do
    case Order.new(params) do
      {:error, changeset} ->
        {:error, {:invalid_order, EctoHelpers.normalize_errors(changeset)}}

      {:ok, _} = ok ->
        ok
    end
  end
end
