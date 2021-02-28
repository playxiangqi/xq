defmodule XQWeb.PageControllerTest do
  use XQWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Play XiangQi"
  end
end
