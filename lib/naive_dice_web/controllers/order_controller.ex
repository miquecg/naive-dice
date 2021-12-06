defmodule NaiveDiceWeb.OrderController do
  use NaiveDiceWeb, :controller

  require Logger

  action_fallback NaiveDiceWeb.FallbackController

  plug :normalize when action in [:create]

  @doc """
  STEP 1: Empty form with user name input
  """
  def new(conn, %{"event_id" => event_id}) do
    with {:ok, event} <- Reservation.event_info(event_id, [:id, :title, :remaining_tickets]) do
      conn
      |> maybe_show_error(event)
      |> render("new.html", %{event: event})
    end
  end

  @doc """
  STEP 2: Payment button
  """
  def edit(conn, %{"id" => token}) do
    with {:ok, %{user_name: name}} <- verify(token) do
      render(conn, "edit.html", name: name, token: token)
    end
  end

  @doc """
  STEP 3: Confirmation screen
  """
  def show(conn, %{"session_id" => session_id}) do
    provider = payment_provider()
    event = {:payment_received, session_id}
    returning = [:user_name]

    with {:ok, data} <- Reservation.notify(provider, event, returning) do
      render(conn, "show.html", data)
    end
  end

  def show(conn, _), do: render_error(conn, 404)

  # TRANSITIONS BETWEEN STEPS

  @doc """
  Books a ticket for 5 minutes
  """
  @salt "ticket booking"
  def create(conn, %{"event_id" => event_id}) do
    user_name = conn.assigns[:user_name]

    with {:ok, booking_id} <- Reservation.book_event(event_id, user_name) do
      data = %{event_id: event_id, booking_id: booking_id, user_name: user_name}
      token = Phoenix.Token.sign(Endpoint, @salt, data)
      redirect(conn, to: Routes.order_path(conn, :edit, token))
    end
  end

  @doc """
  Triggers payment and redirects to payment form
  """
  def update(conn, %{"id" => token}) do
    with {:ok, %{booking_id: booking_id} = data} <- verify(token),
         {:ok, event} = Reservation.event_info(data.event_id, [:title]),
         extra = [client_reference_id: booking_id, description: event.title],
         provider = payment_provider(),
         {:ok, url} <- Reservation.create_checkout(provider, booking_id, extra) do
      conn
      |> put_status(303)
      |> redirect(external: url)
    end
  end

  defp normalize(conn, _opts) do
    conn.params["order"]["user_name"]
    |> String.split()
    |> Enum.join(" ")
    |> String.normalize(:nfc)
    |> then(&assign(conn, :user_name, &1))
  end

  defp maybe_show_error(conn, %{remaining_tickets: 0}) do
    # Erases previous form errors but it doesn't matter.
    put_flash(conn, :error, "Sorry, no tickets left")
  end

  defp maybe_show_error(conn, _), do: conn

  @five_minutes_max_age [max_age: 300]
  defp verify(token) do
    case Phoenix.Token.verify(Endpoint, @salt, token, @five_minutes_max_age) do
      {:ok, _} = ok -> ok
      {:error, error} -> {:error, {:token, error}}
    end
  end

  defp payment_provider do
    {:ok, config} = Application.fetch_env(:naive_dice, Reservation.Payment)
    {:ok, provider} = Keyword.fetch(config, :provider)
    provider
  end
end
