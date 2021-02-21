defmodule XQ.Core.Board do
  alias XQ.Core.{Point}

  def update(board, old_index, new_point) do
    board
    |> Enum.with_index()
    |> remove_piece_at(old_index)
    |> Enum.map(&elem(&1, 0))
    |> maybe_capture_piece(new_point)
  end

  defp remove_piece_at(board, index) do
    Enum.filter(board, fn {_, i} -> i != index end)
  end

  defp maybe_capture_piece(board_state, point) do
    Enum.reject(board_state, &Point.can_capture(&1, point))
  end
end
