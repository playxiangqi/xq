defmodule XQWeb.Schema.Game.Resolvers do
  def get_game(_root, %{id: id}, _info) do
    with {:ok, %{body: content, status: 200}} <-
           Finch.build(:get, XQWeb.Service.archive() <> "/game/#{id}")
           |> Finch.request(XQ.Finch),
         {:ok, content} <- Jason.decode(content, keys: :atoms) do
      {:ok,
       %{
         board_states: XQ.Board.State.generate(Map.get(content, :moves)),
         # TODO: Should be handled during parsing stage, since we cache raw data
         info:
           Map.update!(content, :result, fn
             "Red WIN" -> "Red Victory"
             "Red DRAW" -> "Draw"
             "Red LOSS" -> "Black Victory"
             result -> result
           end)
         # TODO: consider moving this to xq-archive /api/ingest
         #       as the last stage of ETL, so all board_states
         #       are pre-computed asynchronously and save in table as the pristine output
         #       no need for runtime processing on client request
       }}
    else
      {:error, _} ->
        {:error, %{message: "Not found"}}
    end
  end
end
