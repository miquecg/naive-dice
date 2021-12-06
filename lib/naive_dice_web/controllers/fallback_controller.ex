defmodule NaiveDiceWeb.FallbackController do
  use NaiveDiceWeb, :controller

  require Logger

  def call(conn, {:error, :event_not_found}), do: render_error(conn, 404)

  def call(conn, {:error, :no_tickets}), do: redirect_to_first_step(conn)

  def call(conn, {:error, {:invalid_order, %{} = errors}}) do
    call(conn, {:error, {:invalid_order, Keyword.new(errors)}})
  end

  # Let it crash when there are errors not caused by user input.
  def call(conn, {:error, {:invalid_order, [user_name: [message]]}}) do
    conn
    |> put_flash(:error, "Name #{message}")
    |> redirect_to_first_step()
  end

  def call(conn, {:error, {:token, :expired}}) do
    conn
    |> put_flash(:error, "Your payment session expired")
    |> redirect_to_index()
  end

  def call(conn, {:error, {:token, :invalid}}) do
    # Do some logging if it's interesting
    redirect_to_index(conn)
  end

  def call(conn, {:error, error}) do
    Logger.error(error)
    render_error(conn, 500)
  end

  defp redirect_to_first_step(conn) do
    event_id = conn.params["event_id"]
    redirect(conn, to: Routes.event_order_path(conn, :new, event_id))
  end

  defp redirect_to_index(conn) do
    redirect(conn, to: Routes.event_path(conn, :index))
  end
end
