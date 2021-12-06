defmodule Reservation.Order do
  @moduledoc """
  Life cycle of an order throughout the purchase process.
  """

  @behaviour :gen_statem

  alias Reservation.Payment
  alias Reservation.Repo

  def start_link(opts) do
    {name, opts} = Keyword.pop!(opts, :name)
    {order, opts} = Keyword.pop!(opts, :order)
    :gen_statem.start_link(name, __MODULE__, order, opts)
  end

  ## Callbacks

  @impl :gen_statem
  def init(order) do
    actions = [{:next_event, :internal, :check_purchase}]
    {:ok, :booking_requested, order, actions}
  end

  def booking_requested(:enter, :booking_requested = status, order) do
    order = update_progress(order, status)
    {:keep_state, order}
  end

  def booking_requested(:internal, :check_purchase, order) do
    if Repo.ticket_purchased?(order) do
      stop(order, :already_purchased)
    else
      {:next_state, :ticket_booked, order}
    end
  end

  @five_minutes_timeout 300_000
  def ticket_booked(:enter, :booking_requested, order) do
    order = update_progress(order, :ticket_booked)
    actions = [{{:timeout, :booking_expired}, @five_minutes_timeout, nil}]
    {:keep_state, order, actions}
  end

  def ticket_booked({:timeout, :booking_expired = reason}, _content, order) do
    stop(order, reason)
  end

  def ticket_booked({:call, from}, {:create_checkout, provider, extra}, order) do
    result = Payment.Client.create_checkout(provider, order, extra)
    reply = [{:reply, from, result}]

    case result do
      {:ok, _} ->
        actions = [{{:timeout, :booking_expired}, :cancel} | reply]
        {:next_state, :checkout_created, order, actions}

      {:error, _} ->
        :gen_statem.reply(reply)
        stop(order, :checkout_create_failed)
    end
  end

  def checkout_created(:enter, :ticket_booked, order) do
    order = update_progress(order, :checkout_created)
    actions = [{{:timeout, :checkout_expired}, @five_minutes_timeout, nil}]
    {:keep_state, order, actions}
  end

  def checkout_created({:call, from}, :payment_received, order) do
    {:ok, _} = result = Repo.close_order(order)
    reply = {:reply, from, result}
    {:stop_and_reply, :normal, reply}
  end

  def checkout_created({:timeout, :checkout_expired = reason}, _content, order) do
    # Not implemented canceling the pending session on Stripe.
    stop(order, reason)
  end

  @impl :gen_statem
  def callback_mode, do: [:state_functions, :state_enter]

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :temporary
    }
  end

  defp update_progress(order, status) do
    {:ok, order} = Repo.update_progress(order, status)
    order
  end

  defp stop(order, reason) do
    {:ok, order} = Repo.cancel_order(order, reason)
    {:stop, {:canceled, order}}
  end
end
