defmodule XQWeb.Schema.Game.Queries do
  use Absinthe.Schema.Notation

  alias XQWeb.Schema.Game.Resolvers

  input_object :search_filters do
    field :red_player, :string
    field :limit, :integer
  end

  object :game_queries do
    @desc "Get game info and board representation"
    field :game, :game do
      arg :id, non_null(:id)
      arg :search_filters, :search_filters
      resolve &Resolvers.get_game/3
    end
  end
end
