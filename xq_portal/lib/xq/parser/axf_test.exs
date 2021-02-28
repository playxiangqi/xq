defmodule XQ.Parser.AXFTest do
  use ExUnit.Case

  test "Parametrize positional axis notation" do
    assert XQ.Parser.AXF.parametrize(["c", 4, "+", 1]) == %{
             abbrev: "c",
             prev_file: 4,
             dir: "+",
             mvmt: 1
           }
  end
end
