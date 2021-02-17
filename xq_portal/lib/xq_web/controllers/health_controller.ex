defmodule XQWeb.HealthController do
  use XQWeb, :controller

  def index(conn, _params) do
    {:ok, vsn} = :application.get_key(:xq, :vsn)
    build = System.get_env("GIT_COMMIT_HASH")

    conn
    |> put_status(200)
    |> json(%{healthy: true, version: to_string(vsn), build: build, node_name: node()})
  end
end
