defmodule XQNative.EngineTest do
  use ExUnit.Case, async: true

  alias XQNative.Engine

  describe "Engine.split_best_move_and_results/1" do
    test "maximum depth line" do
      info =
        "depth 15 seldepth 21 multipv 1 score cp 44 nodes 572914 nps 347010 hashfull 289 tbhits 0 time 1651 pv g4g5 h10g8 c4c5 b10c8 b1c3 c10e8 h1g3 d10e9 d1e2 a10d10 c1e3 c7c6 c5c6 e8c6 a1d1 d10d1 e1d1 g10e8 b3b7 g7g6 g5g6\nbestmove g4g5 ponder h10g8\n"

      assert {best_move, results} = Engine.split_best_move_and_results(info)
      assert best_move == ["bestmove g4g5 ponder h10g8"]

      assert results == [
               "depth 15 seldepth 21 multipv 1 score cp 44 nodes 572914 nps 347010 hashfull 289 tbhits 0 time 1651 pv g4g5 h10g8 c4c5 b10c8 b1c3 c10e8 h1g3 d10e9 d1e2 a10d10 c1e3 c7c6 c5c6 e8c6 a1d1 d10d1 e1d1 g10e8 b3b7 g7g6 g5g6"
             ]
    end

    test "pv line" do
      info =
        "depth 12 seldepth 16 multipv 1 score cp 48 nodes 163768 nps 339767 tbhits 0 time 482 pv b1c3 h10g8 h3d3 h8h4 c4c5 h4e4 d3d8 d10e9 c3e4 e9d8 h1g3\n"

      assert {[], _results} = Engine.split_best_move_and_results(info)
    end
  end

  test "Engine.serialize_metadata/1" do
    metadata =
      "depth 12 seldepth 16 multipv 1 score cp 48 nodes 163768 nps 339767 tbhits 0 time 482"

    assert Engine.serialize_metadata(metadata) == %{
             "depth" => 12,
             "seldepth" => 16,
             "multipv" => 1,
             "scorecp" => 48,
             "nodes" => 163_768,
             "nps" => 339_767,
             "tbhits" => 0,
             "time" => 482
           }
  end

  test "Engine.serialize_lines/1" do
    lines = ["b1c3 h10g8 h3d3 h8h4 c4c5 h4e4 d3d8 d10e9 c3e4 e9d8 h1g3"]

    assert Engine.serialize_lines(lines) == [
             ["b1c3", "h10g8"],
             ["h3d3", "h8h4"],
             ["c4c5", "h4e4"],
             ["d3d8", "d10e9"],
             ["c3e4", "e9d8"],
             ["h1g3"]
           ]
  end

  test "Engine.serialize_results/1" do
    results = [
      "depth 15 seldepth 21 multipv 1 score cp 44 nodes 572914 nps 347010 hashfull 289 tbhits 0 time 1651 pv g4g5 h10g8 c4c5 b10c8 b1c3 c10e8 h1g3 d10e9 d1e2 a10d10 c1e3 c7c6 c5c6 e8c6 a1d1 d10d1 e1d1 g10e8 b3b7 g7g6 g5g6"
    ]

    assert [%{metadata: _, lines: _}] = Engine.serialize_results(results)
  end
end
