defprotocol Reservation.Payment.Provider do
  @moduledoc """
  Protocol for payment providers.
  """

  alias Reservation.Payment.CheckoutSession
  alias Reservation.Schemas.Order

  @typep basic_auth :: {:basic, {username :: String.t(), password :: String.t()}}

  @spec credentials(t) :: [basic_auth]
  def credentials(provider)

  @typep url :: String.t()
  @typep body :: map()
  @typep form :: {:form, url, body}
  @typep get :: {:get, url}

  @typep request :: form | get

  @spec session_create(t, Order.t(), keyword()) :: request
  def session_create(provider, order, extra)

  @spec session_retrieve(t, String.t()) :: request
  def session_retrieve(provider, session_id)

  @spec parse(t, map()) :: CheckoutSession.t()
  def parse(provider, session)
end
