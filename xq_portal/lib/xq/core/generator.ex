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

  # TODO: Can turn this to match :moves vs. :board, e.g. move notation vs FEN/PGN

  def generate(%{moves: moves}) do
    Logger.info("moves: #{inspect(moves, limit: :infinity)}")

    moves
    |> Enum.reduce([@starting_state], &generate_board_state/2)
    |> Enum.reverse()
    |> to_zero_indices()
  end

  def generate(_), do: [@starting_state] |> to_zero_indices()

  defp to_zero_indices(states) do
    Enum.map(states, fn s -> Enum.map(s, &Point.to_zero_index/1) end)
  end

  defp generate_board_state(next_move, prev_board_states) do
    move = Move.resolve(next_move)

    next_board_state =
      prev_board_states
      |> List.first()
      |> compute_next_state(move)

    [next_board_state | prev_board_states]
  end

  defp compute_next_state(prev_state, {
         ch,
         side,
         file,
         next_file,
         diff_rank,
         is_front
       }) do
    {old_point, index} = Board.find_point(prev_state, ch, side, file, is_front)
    new_point = Point.update(old_point, next_file, diff_rank)
    updated_state = Board.update(prev_state, index, new_point)

    [new_point | updated_state]
  end
end
