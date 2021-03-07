defmodule XQ.Core.MoveTest do
  use ExUnit.Case

  alias XQ.Core.Move

  @old_point %{ch: :soldier, rank: 4, file: 5}

  describe "Move.next/2" do
    test "vertical movement along file" do
      assert Move.next(%Move{next_file: 6, delta_rank: 0}, @old_point) == %{
               ch: :soldier,
               rank: 4,
               file: 6
             }
    end

    test "horizontal movement along rank" do
      assert Move.next(%Move{delta_rank: 2}, @old_point) == %{
               ch: :soldier,
               rank: 6,
               file: 5
             }
    end

    test "vertical/horizontal movement" do
      assert Move.next(%Move{next_file: 1, delta_rank: 1}, @old_point) == %{
               ch: :soldier,
               rank: 5,
               file: 1
             }
    end

    test "vertical/horizontal movement of positional piece" do
      assert Move.next(%Move{next_file: 1}, @old_point) == %{
               ch: :soldier,
               rank: 5,
               file: 1
             }
    end
  end
end
