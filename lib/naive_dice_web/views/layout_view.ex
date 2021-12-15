defmodule NaiveDiceWeb.LayoutView do
  use NaiveDiceWeb, :view

  def flash_msg(conn) do
    assigns = %{
      info: get_flash(conn, :info),
      error: get_flash(conn, :error)
    }

    ~H"""
    <%= render("info.html", assigns) %>
    <%= render("danger.html", assigns) %>
    """
  end

  def render("info.html", %{info: nil}), do: nil

  def render("info.html", assigns) do
    ~H"""
    <div class="alert alert-info"><%= @info %></div>
    """
  end

  def render("danger.html", %{error: nil}), do: nil

  def render("danger.html", assigns) do
    ~H"""
    <div class="alert alert-danger"><%= @error %></div>
    """
  end
end
