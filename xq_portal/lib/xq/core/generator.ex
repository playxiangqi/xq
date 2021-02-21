defmodule XQ.Core.Generator do
  require Logger

  alias XQ.Core.{Board, Move, Point}

  @starting_state [
    %{ch: :chariot, side: :black, rank: 1, file: 1},
    %{ch: :horse, side: :black, rank: 1, file: 2},
    %{ch: :elephant, side: :black, rank: 1, file: 3},
    %{ch: :advisor, side: :black, rank: 1, file: 4},
    %{ch: :general, side: :black, rank: 1, file: 5},
    %{ch: :advisor, side: :black, rank: 1, file: 6},
    %{ch: :elephant, side: :black, rank: 1, file: 7},
    %{ch: :horse, side: :black, rank: 1, file: 8},
    %{ch: :chariot, side: :black, rank: 1, file: 9},
    %{ch: :cannon, side: :black, rank: 3, file: 2},
    %{ch: :cannon, side: :black, rank: 3, file: 8},
    %{ch: :soldier, side: :black, rank: 4, file: 1},
    %{ch: :soldier, side: :black, rank: 4, file: 3},
    %{ch: :soldier, side: :black, rank: 4, file: 5},
    %{ch: :soldier, side: :black, rank: 4, file: 7},
    %{ch: :soldier, side: :black, rank: 4, file: 9},
    %{ch: :soldier, side: :red, rank: 7, file: 1},
    %{ch: :soldier, side: :red, rank: 7, file: 3},
    %{ch: :soldier, side: :red, rank: 7, file: 5},
    %{ch: :soldier, side: :red, rank: 7, file: 7},
    %{ch: :soldier, side: :red, rank: 7, file: 9},
    %{ch: :cannon, side: :red, rank: 8, file: 2},
    %{ch: :cannon, side: :red, rank: 8, file: 8},
    %{ch: :chariot, side: :red, rank: 10, file: 1},
    %{ch: :horse, side: :red, rank: 10, file: 2},
    %{ch: :elephant, side: :red, rank: 10, file: 3},
    %{ch: :advisor, side: :red, rank: 10, file: 4},
    %{ch: :general, side: :red, rank: 10, file: 5},
    %{ch: :advisor, side: :red, rank: 10, file: 6},
    %{ch: :elephant, side: :red, rank: 10, file: 7},
    %{ch: :horse, side: :red, rank: 10, file: 8},
    %{ch: :chariot, side: :red, rank: 10, file: 9}
  ]

  # TODO: Rename module to Core and this file to Generator
  # Can have XQ.Core.Generator, XQ.Core.Board, and XQ.Core.Point

  def generate(nil), do: [@starting_state] |> to_zero_indices()

  def generate(moves) do
    moves
    |> Enum.reduce([@starting_state], &generate_board_state/2)
    |> Enum.reverse()
    |> to_zero_indices()
  end

  defp to_zero_indices(states) do
    Enum.map(states, fn s -> Enum.map(s, &Point.to_zero_index/1) end)
  end

  defp generate_board_state(next_move, prev_board_states) do
    move = Move.resolve(next_move)

    next_board_state =
      prev_board_states
      |> List.first()
      |> update_board_state(move)

    [next_board_state | prev_board_states]
  end

  defp update_board_state(board_state, {
         ch,
         side,
         file,
         next_file,
         diff_rank,
         is_front
       }) do
    points_to_move =
      board_state
      |> Enum.with_index()
      |> get_matching_points(ch, side, file)
      |> sort_front_rear_rank(side)

    {point, index} =
      if is_front,
        do: List.first(points_to_move),
        else: List.last(points_to_move)

    new_point = Point.update(point, next_file, diff_rank)
    updated_board_state = Board.update(board_state, index, new_point)

    [new_point | updated_board_state]
  end

  defp get_matching_points(board_state, ch, side, file) do
    board_state
    |> Enum.filter(fn {p, _} -> p.ch == ch and p.side == side end)
    |> Enum.filter(fn {p, _} -> p.file == file or file == -1 or file == 11 end)
  end

  defp sort_front_rear_rank(board_state, side) do
    Enum.sort(board_state, fn {a, _}, {b, _} ->
      Point.by_rank(side, a, b)
    end)
  end
end
