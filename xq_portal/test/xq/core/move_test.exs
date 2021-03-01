defmodule XQ.Core.MoveTest do
  use ExUnit.Case

  alias XQ.Core.Move

  @old_point %{ch: :soldier, rank: 4, file: 5}

  test "Vertical movement along file" do
    assert Move.to_new_point(%Move{next_file: 6, delta_rank: 0}, @old_point) == %{
             ch: :soldier,
             rank: 4,
             file: 6
           }
  end

  test "Horizontal movement along rank" do
    assert Move.to_new_point(%Move{delta_rank: 2}, @old_point) == %{
             ch: :soldier,
             rank: 6,
             file: 5
           }
  end

  test "Vertical/horizontal movement" do
    assert Move.to_new_point(%Move{next_file: 1, delta_rank: 1}, @old_point) == %{
             ch: :soldier,
             rank: 5,
             file: 1
           }
  end

  test "Vertical/horizontal movement of positional piece" do
    assert Move.to_new_point(%Move{next_file: 1}, @old_point) == %{
             ch: :soldier,
             rank: 5,
             file: 1
           }
  end
end
