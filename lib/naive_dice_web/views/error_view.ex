defmodule NaiveDiceWeb.ErrorView do
  use NaiveDiceWeb, :view

  def render("404.html", _assigns) do
    "HTTP 404: resource not found"
  end

  def template_not_found(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end
end
