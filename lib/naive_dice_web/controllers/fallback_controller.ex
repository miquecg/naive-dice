defmodule NaiveDiceWeb.FallbackController do
  use NaiveDiceWeb, :controller

  alias NaiveDiceWeb.ErrorView

  def call(conn, {:error, :event_not_found}) do
    conn
    |> put_status(404)
    |> render_error()
  end

  def call(conn, {:error, :no_tickets}), do: redirect_first_step(conn)

  def call(conn, {:error, {:invalid_order, %{} = errors}}) do
    call(conn, {:error, {:invalid_order, Keyword.new(errors)}})
  end

  # Let it crash when there are errors not caused by user input.
  def call(conn, {:error, {:invalid_order, [user_name: [message]]}}) do
    conn
    |> put_flash(:error, "Name #{message}")
    |> redirect_first_step()
  end

  defp render_error(conn) do
    conn
    |> put_layout(false)
    |> put_view(ErrorView)
    |> render(:"#{conn.status}")
  end

  defp redirect_first_step(conn) do
    event_id = conn.params["event_id"]
    redirect(conn, to: Routes.event_order_path(conn, :new, event_id))
  end
end
