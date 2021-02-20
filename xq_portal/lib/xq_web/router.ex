defmodule XQWeb.Router do
  use XQWeb, :router

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

  scope "/", XQWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/health", HealthController, :index
  end

  scope "/api", XQWeb do
    pipe_through :api

    get "/analysis/game", AnalysisController, :analyze_game
  end

  scope "/graphql" do
    forward "/ui", Absinthe.Plug.GraphiQL,
      schema: XQWeb.GraphQL.Schemas.Opening,
      default_url: "http://localhost:4000/graphql",
      interface: :playground

    forward "/", Absinthe.Plug, schema: XQWeb.GraphQL.Schemas.Opening
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: XQWeb.Telemetry
    end
  end
end
