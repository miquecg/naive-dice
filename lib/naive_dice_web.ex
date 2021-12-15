defmodule NaiveDiceWeb do
  @moduledoc false

  def controller do
    quote do
      use Phoenix.Controller, namespace: NaiveDiceWeb

      import Plug.Conn
      import NaiveDiceWeb.Controller.Error

      alias NaiveDiceWeb.Endpoint
      alias NaiveDiceWeb.Router.Helpers, as: Routes
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/naive_dice_web/templates",
        namespace: NaiveDiceWeb

      import Phoenix.Controller,
        only: [get_flash: 1, get_flash: 2, view_module: 1, view_template: 1]

      unquote(view_helpers())
    end
  end

  def router do
    quote do
      use Phoenix.Router

      import Plug.Conn
      import Phoenix.Controller
    end
  end

  defp view_helpers do
    quote do
      use Phoenix.HTML

      import Phoenix.LiveView.Helpers
      import Phoenix.View

      alias NaiveDiceWeb.Router.Helpers, as: Routes
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
