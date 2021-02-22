defmodule XQWeb.Schema.Game.Resolvers do
  def get_game(_root, %{id: id}, _info) do
    with {:ok, %{body: content, status: 200}} <-
           Finch.build(:get, XQWeb.Service.archive() <> "/game/#{id}")
           |> Finch.request(XQ.Finch),
         {:ok, content} <- Jason.decode(content, keys: :atoms) do
      {:ok,
       %{
         # TODO:
         #  Consider moving board state generation as part of ETL pipeline
         #  Entire asynchronous processing, simply serve client-side pristine
         #  output immediately that is DB cached.
         #
         # However:
         #  Run-time processing gives the most flexibility, since
         #  there is minimal support and an assumption of only one move notation.
         board_states: XQ.Generator.generate(content),
         info: content
       }}
    else
      {:error, _} ->
        {:error, %{message: "Not found"}}
    end
  end
end
