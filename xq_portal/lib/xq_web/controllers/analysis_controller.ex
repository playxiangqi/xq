defmodule XQWeb.AnalysisController do
  use XQWeb, :controller

  def analyze_game(conn, _params) do
    with {:ok, %{body: content, status: 200}} <-
           Finch.build(:get, XQWeb.Service.archive() <> "/game")
           |> Finch.request(XQ.Finch),
         {:ok, content} <- Jason.decode(content),
         game_info <- List.first(content) do
      # TODO: realistically, this would be GET /analysis/game + specific ID
      json(conn, %{
        game_info:
          Map.update!(game_info, "result", fn
            "Red WIN" -> "Red Victory"
            "Red DRAW" -> "Draw"
            "Red LOSS" -> "Black Victory"
            result -> result
          end),
        # TODO: consider moving this to xq-archive /api/ingest
        #       as the last stage of ETL, so all board_states
        #       are pre-computed asynchronously and save in table as the pristine output
        #       no need for runtime processing on client request
        board_states: XQ.Board.State.generate(Map.get(game_info, "moves"))
      })
    else
      {:error, _} ->
        conn |> put_status(:not_found) |> render(:"404")
    end
  end
end
