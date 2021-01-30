defmodule XQ.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      XQ.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: XQ.PubSub}
      # Start a worker by calling: XQ.Worker.start_link(arg)
      # {XQ.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: XQ.Supervisor)
  end
end
