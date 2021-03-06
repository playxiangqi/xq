defmodule XQ.Core.Board do
  alias XQ.Core.{Point, Move}

  require Logger

  defstruct [:state, :prev_point, :next_point]

  @type t :: %__MODULE__{
          state: list(Point),
          prev_point: Point | nil,
          next_point: Point | nil
        }

  def update(board, next_point, old_index) do
    board
    |> remove_piece_at(old_index)
    |> maybe_capture_piece(next_point)
  end

  def find_point(board, %Move{ch: ch, side: side} = move) do
    potential_points =
      board
      |> Enum.with_index()
      |> Enum.filter(fn {p, _} ->
        Point.is_matching(p, %{ch: ch, side: side, file: move.prev_file})
      end)
      |> get_tandem_soldier(move)
      |> Enum.sort(fn {a, _}, {b, _} ->
        Point.by_rank(side, a, b)
      end)

    if move.is_front,
      do: List.first(potential_points),
      else: List.last(potential_points)
  end

  defp get_tandem_soldier(points, %Move{ch: :soldier}) do
    Logger.debug("matching points: #{inspect(points)}")

    potential_points =
      points
      |> Enum.group_by(fn {p, _i} ->
        Map.get(p, :file, nil)
      end)

    Logger.debug("grouped points: #{inspect(potential_points)}")

    potential_points =
      if map_size(potential_points) == 1,
        do: List.first(Map.values(potential_points)),
        else:
          Enum.find_value(potential_points, fn {_file, matching_points} ->
            Logger.debug("same file: #{inspect(matching_points)}")
            if length(matching_points) > 1, do: matching_points
          end)

    Logger.debug("tandem soldier potential points: #{inspect(potential_points)}")

    potential_points
  end

  defp get_tandem_soldier(points, _move), do: points

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
