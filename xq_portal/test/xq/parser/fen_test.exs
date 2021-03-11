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
          %{ch: :horse, side: :red, rank: 3, file: 7},
          %{ch: :advisor, side: :red, rank: 8, file: 4},
          %{ch: :soldier, side: :black, rank: 8, file: 5},
          %{ch: :chariot, side: :black, rank: 8, file: 7},
          %{ch: :advisor, side: :red, rank: 9, file: 3},
          %{ch: :general, side: :red, rank: 9, file: 4},
          %{ch: :cannon, side: :black, rank: 9, file: 8}
        ]
      }

      assert FEN.produce(board) == "4kaR2/4a4/3hR4/7H1/9/9/9/9/4Ap1r1/3AK3c w---1"
    end
  end
end
