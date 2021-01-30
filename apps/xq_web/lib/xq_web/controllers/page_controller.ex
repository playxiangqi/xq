defmodule XQWeb.PageController do
  use XQWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
