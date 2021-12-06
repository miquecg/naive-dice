defmodule NaiveDiceWeb.Controller.Error do
  @moduledoc """
  Renders the ErrorView.
  """

  import Phoenix.Controller, only: [put_layout: 2, put_view: 2, render: 2]

  def render_error(conn, status) when is_integer(status) do
    conn
    |> Plug.Conn.put_status(status)
    |> put_layout(false)
    |> put_view(ErrorView)
    |> render(:"#{status}")
  end
end
