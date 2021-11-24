defmodule NaiveDiceWeb.Router do
  use NaiveDiceWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", NaiveDiceWeb do
    pipe_through :browser

    get "/", EventController, :index

    resources("/events", EventController, only: [:index, :show]) do
      resources("/tickets", TicketController, only: [:new, :create])
    end

    # event_id is captured on a Ticket already - no need to have it in a route
    resources("/tickets", TicketController, only: [:edit, :update, :show])

    resources("/guests", GuestController, only: [:index])
    delete "/guests/reset", GuestController, :reset_guests
  end

  # Other scopes may use custom stacks.
  # scope "/api", NaiveDiceWeb do
  #   pipe_through :api
  # end
end
