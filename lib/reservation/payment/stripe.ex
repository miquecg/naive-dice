defmodule Reservation.Payment.Stripe do
  @moduledoc """
  Payment provider implementation for Stripe.
  """

  alias Reservation.Payment
  alias Reservation.Payment.CheckoutSession
  alias Reservation.Schemas.Order

  @enforce_keys [
    :checkout_url,
    :api_key,
    :success_url,
    :cancel_url
  ]
  @derive {Inspect, except: [:api_key]}
  defstruct @enforce_keys

  def configure(opts), do: struct!(__MODULE__, opts)

  defimpl Payment.Provider do
    def credentials(%{api_key: username}), do: [{:basic, {username, ""}}]

    def session_create(stripe, %Order{} = order, extra \\ []) do
      body =
        %{
          "success_url" => success_url(stripe),
          "cancel_url" => cancel_url(stripe),
          "mode" => "payment"
        }
        |> put_line_items(order, extra)
        |> merge({:client_reference_id, extra})

      {:form, stripe.checkout_url, body}
    end

    def session_retrieve(stripe, session_id) do
      {:get, Path.join([stripe.checkout_url, session_id])}
    end

    def parse(_, session_data) do
      CheckoutSession.new(%{
        id: session_data["id"],
        booking_id: session_data["client_reference_id"],
        url: session_data["url"],
        payment_status: session_data["payment_status"]
      })
    end

    # Assume URL doesn't have query params already.
    defp success_url(stripe), do: stripe.success_url <> query_param()

    defp cancel_url(stripe), do: stripe.cancel_url

    @session_id "{CHECKOUT_SESSION_ID}"
    defp query_param, do: "?session_id=#{@session_id}"

    defp put_line_items(body, order, extra) do
      %{
        "quantity" => 1,
        "currency" => "eur",
        "amount" => order.price_cents,
        "name" => "Naive Dice"
      }
      |> merge({:description, extra})
      |> Enum.map(&line_items_entry/1)
      |> Enum.into(body)
    end

    defp line_items_entry({key, value}), do: {"line_items[0][#{key}]", value}

    defp merge(data, {key, extra}) do
      extra
      |> Keyword.take([key])
      |> Enum.into(data, &key_to_string/1)
    end

    defp key_to_string({key, value}), do: {Atom.to_string(key), value}
  end
end
