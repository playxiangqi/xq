defmodule XQ.Core.Board do
  alias XQ.Core.{Point}

  def update(board, old_index, new_point) do
    board
    |> remove_piece_at(old_index)
    |> maybe_capture_piece(new_point)
  end

  defp remove_piece_at(board, index) do
    board
    |> Enum.with_index()
    |> Enum.filter(fn {_, i} -> i != index end)
    |> Enum.map(&elem(&1, 0))
  end

  defp maybe_capture_piece(board_state, point) do
    Enum.reject(board_state, &Point.can_capture(&1, point))
  end
end
