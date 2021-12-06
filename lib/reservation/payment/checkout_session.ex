defmodule Reservation.Payment.CheckoutSession do
  @type t :: %__MODULE__{}

  @enforce_keys [:id, :booking_id, :url, :payment_status]
  defstruct @enforce_keys

  def new(%{} = params) do
    params = Map.update!(params, :payment_status, &to_atom/1)
    struct!(__MODULE__, params)
  end

  defp to_atom(status) when is_atom(status), do: status

  defp to_atom("paid"), do: :paid
  defp to_atom("unpaid"), do: :unpaid
  defp to_atom("no_payment_required"), do: :no_payment_required
end
