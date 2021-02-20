defmodule XQWeb.Schema.Game.Resolvers do
  def get_game(_root, _args, _info) do
    with {:ok, %{body: content, status: 200}} <-
           Finch.build(:get, XQWeb.Service.archive() <> "/game")
           |> Finch.request(XQ.Finch),
         {:ok, content} <- Jason.decode(content, keys: :atoms),
         game_info <- List.first(content) do
      # TODO: realistically, this would be GET /analysis/game + specific ID
      %{
        board_states: XQ.Board.State.generate(Map.get(game_info, :moves)),
        info:
          Map.update!(game_info, :result, fn
            "Red WIN" -> "Red Victory"
            "Red DRAW" -> "Draw"
            "Red LOSS" -> "Black Victory"
            result -> result
          end)
        # TODO: consider moving this to xq-archive /api/ingest
        #       as the last stage of ETL, so all board_states
        #       are pre-computed asynchronously and save in table as the pristine output
        #       no need for runtime processing on client request
      }
    else
      {:error, _} ->
        {:error, %{message: "Not found"}}
    end
  end
end
