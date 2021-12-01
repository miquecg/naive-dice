defmodule Reservation do
  @moduledoc """
  Entrypoint to the reservation system.
  """

  alias Reservation.EctoHelpers
  alias Reservation.EventBooker
  alias Reservation.Repo
  alias Reservation.Schemas.{Event, Order}

  def all_events_info(keys) do
    events = Repo.all(Event)
    Enum.map(events, &build_info(&1, keys))
  end

  def event_info(event_id, keys) do
    # It would be good to optimise this a little an
    # avoid hitting database for non existing events.
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

  defp build_info(%Event{id: id} = event, keys) do
    Enum.reduce(keys, %{id: id}, &build_info(event, &1, &2))
  end

  defp build_info(event, :remaining_tickets = k, acc) do
    # Event must exist on EventBooker if it exists on database.
    {:ok, remaining} = EventBooker.remaining_tickets(event.id)
    Map.put(acc, k, remaining)
  end

  defp build_info(event, key, acc) when is_map_key(event, key) do
    Map.put(acc, key, Map.get(event, key))
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
