defmodule XQ.Parser.AXFTest do
  use ExUnit.Case

  @axis ~w(P p C c R r K k)
  @direction ~w(+ = -)
  @position ~w(+ -)
  @range 0..9

  test "Parametrize exact axis notation" do
    matches = Enum.map([@axis, @range, @direction, @range], &Enum.random(&1))
    params = XQ.Parser.AXF.parametrize(matches)

    assert Map.has_key?(params, :abbrev)
    assert Map.has_key?(params, :prev_file)
    assert Map.has_key?(params, :dir)
    assert Map.has_key?(params, :mvmt)
  end

  test "Parametrize positional axis notation" do
    matches = Enum.map([@position, @axis, @direction, @range], &Enum.random(&1))
    params = XQ.Parser.AXF.parametrize(matches)

    assert Map.has_key?(params, :pos)
    assert Map.has_key?(params, :abbrev)
    assert Map.has_key?(params, :dir)
    assert Map.has_key?(params, :mvmt)
  end
end
