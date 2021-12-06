defmodule NaiveDice.Application do
  @moduledoc false

  use Application

  alias NaiveDiceWeb.Router.Helpers, as: Routes
  alias Reservation.Payment

  @impl Application
  def start(_type, _args) do
    children = [
      Reservation.Repo,
      {Registry, keys: :unique, name: Registry.Orders},
      Reservation.EventBookerSupervisor,
      {Phoenix.PubSub, [name: NaiveDice.PubSub, adapter: Phoenix.PubSub.PG2]},
      NaiveDiceWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: NaiveDice.Supervisor]
    {:ok, _pid} = return = Supervisor.start_link(children, opts)

    configure_payment()
    return
  end

  @impl Application
  def config_change(changed, _new, removed) do
    NaiveDiceWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp configure_payment do
    {:ok, opts} = Application.fetch_env(:naive_dice, Stripe)

    opts = add_callback_urls(opts)
    stripe = Payment.Stripe.configure(opts)
    :ok = Application.put_env(:naive_dice, Payment, provider: stripe)
  end

  defp add_callback_urls(opts) do
    base_url = NaiveDiceWeb.Endpoint.url()
    path = Routes.order_path(NaiveDiceWeb.Endpoint, :show)
    # Canceled checkouts are simply ignored.
    Keyword.merge(opts, success_url: base_url <> path, cancel_url: base_url)
  end
end
