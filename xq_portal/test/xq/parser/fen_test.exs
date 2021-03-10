defmodule XQ.Parser.FENTest do
  use ExUnit.Case, async: true

  alias XQ.Core.Board
  alias XQ.Parser.FEN

  describe "produce/1" do
    test "produce FEN from internal board representation" do
      board = %Board{
        state: [
          %{ch: :general, side: :black, rank: 0, file: 4},
          %{ch: :advisor, side: :black, rank: 0, file: 5}
        ]
      }

      assert FEN.produce(board) == "4ka w---1"
    end
  end
end
