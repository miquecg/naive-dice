defmodule NaiveDiceWeb.Router do
  use NaiveDiceWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", NaiveDiceWeb do
    pipe_through :browser

    get "/", EventController, :index

    resources("/events", EventController, only: [:index]) do
      resources("/orders", OrderController, only: [:new, :create])
    end

    resources("/orders", OrderController, only: [:edit, :update])

    get "/orders", OrderController, :show

    resources("/guests", GuestController, only: [:index])

    delete "/guests/reset", GuestController, :reset_guests
  end
end
