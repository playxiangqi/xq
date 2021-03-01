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
           board_states: XQ.Generator.generate(content),
           info: content
         }}

      error ->
        error
    end
  end

  def get_game_info(_root, %{} = args, _info) do
    query_string =
      args
      |> URI.encode_query()
      |> String.replace("opening_code", "opening_id")

    fetch_games("?#{query_string}")
  end

  defp fetch_games(query_string) do
    case Finch.request(
           Finch.build(:get, "#{XQWeb.Service.archive()}/game#{query_string}"),
           XQ.Finch
         ) do
      {:ok, %{body: content, status: 200}} ->
        Jason.decode(content, keys: :atoms)

      {:error, _} ->
        {:error, %{message: "Not found"}}
    end
  end
end
