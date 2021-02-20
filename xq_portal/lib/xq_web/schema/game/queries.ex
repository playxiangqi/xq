defmodule XQWeb.Schema.Game.Queries do
  use Absinthe.Schema.Notation

  alias XQWeb.Schema.Game.Resolvers

  object :game_queries do
    @desc "Get full board representation and metadata for a single game"
    field :game, :game do
      arg :id, non_null(:id)
      resolve &Resolvers.get_game/3
    end
  end
end
