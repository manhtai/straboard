defmodule StravamateWeb.Router do
  use StravamateWeb, :router

  alias StravamateWeb.Plugs

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {StravamateWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug(Plugs.SetCurrentUserOnAssigns)
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :authentication_required do
    plug(Plugs.RedirectUnauthenticated)
  end

  scope "/auth", StravamateWeb do
    pipe_through :browser

    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
    post "/:provider/callback", AuthController, :callback
    delete "/logout", AuthController, :delete
  end

  scope "/events", StravamateWeb do
    pipe_through([:browser, :authentication_required])

    post "/join_event", EventController, :join
    post "/leave_event", EventController, :leave

    resources("/", EventController)
  end

  scope "/", StravamateWeb do
    pipe_through :browser

    get "/:code", EventController, :show_by_code
    get "/", PageController, :index
  end

  # scope "/", StravamateWeb do
  #   pipe_through :browser

  #   live "/", PageLive, :index
  # end

  # Other scopes may use custom stacks.
  # scope "/api", StravamateWeb do
  #   pipe_through :api
  # end

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
      live_dashboard "/dashboard", metrics: StravamateWeb.Telemetry
    end
  end
end
