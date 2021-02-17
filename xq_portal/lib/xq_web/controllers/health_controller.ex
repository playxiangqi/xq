defmodule XQWeb.HealthController do
  use XQWeb, :controller

  def index(conn, _params) do
    {:ok, vsn} = :application.get_key(:xq, :vsn)

    conn
    |> put_status(200)
    |> json(%{
      healthy: true,
      version: to_string(vsn),
      build: Application.get_env(:xq, :build),
      node_name: node()
    })
  end
end
