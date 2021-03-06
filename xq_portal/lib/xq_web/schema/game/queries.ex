defmodule XQWeb.Schema.Game.Queries do
  use Absinthe.Schema.Notation

  alias XQWeb.Schema.Game.Resolvers

  input_object :search_game_filter do
    field :red_player, :string
    field :black_player, :string
    field :opening_code, :string
    field :result, :string
    field :limit, :integer
    field :min_moves, :integer
    field :max_moves, :integer
  end

  object :game_queries do
    @desc "Get list of games based on a variety of search filters"
    field :games, list_of(:game_info) do
      arg :filter, non_null(:search_game_filter)
      resolve &Resolvers.get_game_info/3
    end

    @desc "Get full board representation/metadata for a specific game"
    field :game, :game do
      arg :id, non_null(:id)
      resolve &Resolvers.get_game/3
    end
  end
end
