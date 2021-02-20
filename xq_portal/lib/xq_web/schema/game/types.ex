defmodule XQWeb.Schema.Game.Types do
  use Absinthe.Schema.Notation

  object :game_info do
    field :id, non_null(:integer)
    field :source_id, non_null(:string)
    field :source, non_null(:string)
    field :result, non_null(:string)
    field :red_player, non_null(:string)
    field :black_player, non_null(:string)
    field :opening_code, non_null(:string)
    field :opening_name, non_null(:string)
    field :event, non_null(:string)
    field :date, non_null(:string)
    field :red_club, :string
    field :red_rating, :integer
    field :black_club, :string
    field :black_rating, :integer
    field :moves, non_null(list_of(:string))
  end

  object :point do
    field :ch, non_null(:string)
    field :side, non_null(:string)
    field :rank, non_null(:integer)
    field :file, non_null(:integer)
  end

  object :game do
    field :info, non_null(:game_info)
    field :board_states, non_null(list_of(list_of(:point)))
  end
end
