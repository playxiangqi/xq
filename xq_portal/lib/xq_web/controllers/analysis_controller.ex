defmodule XQWeb.AnalysisController do
  use XQWeb, :controller

  def analyze_game(conn, _params) do
    with {:ok, %{body: content, status: 200}} <-
           Finch.build(:get, archive_service() <> "/game")
           |> Finch.request(XQ.Finch),
         {:ok, content} <- Jason.decode(content),
         game_info <- List.first(content) do
      # TODO: realistically, this would be GET /analysis/game + specific ID
      json(conn, %{
        game_info: game_info,
        board_states: XQ.Board.State.generate(Map.get(game_info, "moves"))
      })
    else
      {:error, _} ->
        conn |> put_status(:not_found) |> render(:"404")
    end
  end

  defp archive_service, do: Application.get_env(:xq, :archive_service)
end
