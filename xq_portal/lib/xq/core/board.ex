defmodule XQ.Core.Board do
  alias XQ.Core.{Point}

  def update(board, old_index, new_point) do
    board
    |> remove_piece_at(old_index)
    |> maybe_capture_piece(new_point)
  end

  def find_point(board, ch, side, file, is_front) do
    potential_points =
      board
      |> Enum.with_index()
      |> Enum.filter(fn {p, _} ->
        Point.is_matching(p, %{ch: ch, side: side, file: file})
      end)
      |> Enum.sort(fn {a, _}, {b, _} ->
        Point.by_rank(side, a, b)
      end)

    if is_front,
      do: List.first(potential_points),
      else: List.last(potential_points)
  end

  defp remove_piece_at(board, index) do
    board
    |> Enum.with_index()
    |> Enum.filter(fn {_, i} -> i != index end)
    |> Enum.map(&elem(&1, 0))
  end

  defp maybe_capture_piece(board, point) do
    Enum.reject(board, &Point.can_capture(&1, point))
  end
end
