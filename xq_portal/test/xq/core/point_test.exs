defmodule XQ.Core.PointTest do
  use ExUnit.Case

  alias XQ.Core.Point

  test "to_zero_index/1" do
    assert Point.to_zero_index([%{rank: 7, file: 6}, %{rank: 10, file: 2}]) == [
             %{rank: 6, file: 5},
             %{rank: 9, file: 1}
           ]
  end
end
