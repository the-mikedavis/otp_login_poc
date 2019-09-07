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

  scope "/", OneWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  scope "/login", OneWeb do
    pipe_through :browser
  end
end
