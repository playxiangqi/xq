defmodule XQ.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      XQ.Repo,
      # Start the Telemetry supervisor
      XQWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: XQ.PubSub},
      # Start the Endpoint (HTTP/HTTPS)
      XQWeb.Endpoint,
      # Start the Finch HTTP Client pools
      {Finch, name: XQ.Finch},
      # Start the XQ Engine supervisor
      XQNative.Supervisor
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: XQ.Supervisor]
    Supervisor.start_link(children, opts)

    DynamicSupervisor.start_child(XQNative.Supervisor, {XQNative.Engine, self()})
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    XQWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
