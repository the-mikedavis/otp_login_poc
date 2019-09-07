defmodule OneWeb.Router do
  use OneWeb, :router

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

  pipeline :auth do
    plug OneWeb.SessionPlug
  end

  scope "/", OneWeb do
    pipe_through ~w(browser auth)a

    get "/", PageController, :index
  end

  scope "/login", OneWeb do
    pipe_through :browser

    resources "/", LoginController, only: [:index, :create, :delete]
  end
end
