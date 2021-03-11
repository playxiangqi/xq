defmodule XQ.Parser.FENTest do
  use ExUnit.Case, async: true

  alias XQ.Core.Board
  alias XQ.Parser.FEN

  describe "produce/1" do
    test "produce FEN from internal board representation" do
      board = %Board{
        state: [
          %{ch: :general, side: :black, rank: 0, file: 4},
          %{ch: :advisor, side: :black, rank: 0, file: 5},
          %{ch: :chariot, side: :red, rank: 0, file: 6},
          %{ch: :advisor, side: :black, rank: 1, file: 4},
          %{ch: :horse, side: :black, rank: 2, file: 3},
          %{ch: :chariot, side: :red, rank: 2, file: 4},
          %{ch: :horse, side: :red, rank: 3, file: 7}
        ]
      }

      assert FEN.produce(board) == "4kaR2/4a4/3hR4/7H1 w---1"
    end
  end
end
