defmodule XQ.Core.BoardTest do
  use ExUnit.Case, async: true

  alias XQ.Core.{Board, Move, Point}

  describe "Board.find_tandem_soldiers/2" do
    test "next move is not a soldier move" do
      elephant_point = [%{ch: :soldier, side: :red, rank: 5, file: 7}]

      assert Board.find_tandem_soldiers(
               elephant_point,
               %Move{ch: :elephant}
             ) == elephant_point
    end
  end
end
