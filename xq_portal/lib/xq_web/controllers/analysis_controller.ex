defmodule XQWeb.AnalysisController do
  use XQWeb, :controller

  def analyze_game(conn, _params) do
    with {:ok, %{body: content, status: 200}} <-
           Finch.build(:get, archive_service() <> "/game")
           |> Finch.request(XQ.Finch),
         {:ok, content} <- Jason.decode(content) do
      json(conn, %{
        game_info: List.first(content),
        board_states: [XQ.Board.State.get_starting_state()]
      })
    else
      {:error, _} ->
        conn |> put_status(:not_found) |> render(:"404")
    end
  end

  defp archive_service, do: Application.get_env(:xq, :archive_service)
end
