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
    |> List.delete_at(old_index)
    |> Enum.reject(&Point.can_capture(&1, next_point))
  end

  def find_point(board, %Move{ch: ch, side: side, prev_file: file} = move) do
    potential_points =
      board
      |> Enum.filter(&Point.is_matching(&1, %{ch: ch, side: side, file: file}))
      |> find_tandem_soldiers(move)
      |> Enum.sort(&Point.by_rank(side, &1, &2))

    found_point =
      if move.is_front,
        do: List.first(potential_points),
        else: List.last(potential_points)

    {found_point, Enum.find_index(board, &(&1 == found_point))}
  end

  def find_tandem_soldiers(points, %Move{ch: ch})
      when length(points) == 1 or ch != :soldier,
      do: points

  def find_tandem_soldiers(points, %Move{ch: :soldier}) do
    points
    |> Enum.group_by(&Map.get(&1, :file))
    |> Enum.find_value(fn {_file, soldiers} ->
      if length(soldiers) > 1, do: soldiers
    end)
  end
end
