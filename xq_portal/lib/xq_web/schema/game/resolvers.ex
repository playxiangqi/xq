defmodule XQWeb.Schema.Game.Resolvers do
  require Logger

  def get_game(_root, %{id: id}, _info) do
    case fetch_games("/#{id}") do
      {:ok, content} ->
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
           board_states: XQ.Core.Generator.generate(content),
           info: content
         }}

      error ->
        error
    end
  end

  def get_game_info(_root, %{} = args, _info) do
    fetch_games("?#{URI.encode_query(args)}")
  end

  defp fetch_games(query_string) do
    with {:ok, %{body: content, status: 200}} <-
           Finch.build(:get, XQWeb.Service.archive() <> "/game#{query_string}")
           |> Finch.request(XQ.Finch) do
      Jason.decode(content, keys: :atoms)
    else
      {:error, _} ->
        {:error, %{message: "Not found"}}
    end
  end
end
