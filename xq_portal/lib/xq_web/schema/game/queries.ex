defmodule XQWeb.Schema.Game.Queries do
  use Absinthe.Schema.Notation

  alias XQWeb.Schema.Game.Resolvers

  object :game_queries do
    @desc "Get list of games based on a variety of search filters"
    field :games, list_of(:game_info) do
      arg :red_player, :string
      arg :black_player, :string
      arg :opening_code, :string
      arg :result, :string
      arg :limit, :integer
      resolve &Resolvers.get_game_info/3
    end

    @desc "Get full board representation/metadata for a specific game"
    field :game, :game do
      arg :id, non_null(:id)
      resolve &Resolvers.get_game/3
    end
  end
end
