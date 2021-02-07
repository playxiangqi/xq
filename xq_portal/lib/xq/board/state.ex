defmodule XQ.Board.State do
  @starting_state [
    %{piece: :chariot, side: :black, rank: 1, file: 1},
    %{piece: :horse, side: :black, rank: 1, file: 2},
    %{piece: :elephant, side: :black, rank: 1, file: 3},
    %{piece: :advisor, side: :black, rank: 1, file: 4},
    %{piece: :general, side: :black, rank: 1, file: 5},
    %{piece: :advisor, side: :black, rank: 1, file: 6},
    %{piece: :elephant, side: :black, rank: 1, file: 7},
    %{piece: :horse, side: :black, rank: 1, file: 8},
    %{piece: :chariot, side: :black, rank: 1, file: 9},
    %{piece: :cannon, side: :black, rank: 3, file: 2},
    %{piece: :cannon, side: :black, rank: 3, file: 8},
    %{piece: :soldier, side: :black, rank: 4, file: 1},
    %{piece: :soldier, side: :black, rank: 4, file: 3},
    %{piece: :soldier, side: :black, rank: 4, file: 5},
    %{piece: :soldier, side: :black, rank: 4, file: 7},
    %{piece: :soldier, side: :black, rank: 4, file: 9},
    %{piece: :soldier, side: :red, rank: 7, file: 1},
    %{piece: :soldier, side: :red, rank: 7, file: 3},
    %{piece: :soldier, side: :red, rank: 7, file: 5},
    %{piece: :soldier, side: :red, rank: 7, file: 7},
    %{piece: :soldier, side: :red, rank: 7, file: 9},
    %{piece: :cannon, side: :red, rank: 8, file: 2},
    %{piece: :cannon, side: :red, rank: 8, file: 8},
    %{piece: :chariot, side: :red, rank: 10, file: 1},
    %{piece: :horse, side: :red, rank: 10, file: 2},
    %{piece: :elephant, side: :red, rank: 10, file: 3},
    %{piece: :advisor, side: :red, rank: 10, file: 4},
    %{piece: :general, side: :red, rank: 10, file: 5},
    %{piece: :advisor, side: :red, rank: 10, file: 6},
    %{piece: :elephant, side: :red, rank: 10, file: 7},
    %{piece: :horse, side: :red, rank: 10, file: 8},
    %{piece: :chariot, side: :red, rank: 10, file: 9}
  ]

  def get_starting_state do
    to_zero_index(@starting_state)
  end

  defp to_zero_index(state) do
    Enum.map(state, fn p ->
      %{
        piece: p.piece,
        side: p.side,
        rank: p.rank - 1,
        file: p.file - 1
      }
    end)
  end
end
