defmodule XQ.Generator do
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

  def generate(%{id: id, moves: moves}) do
    Logger.info("id: #{id}")
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
    # TODO: Currently hard-coded but should be passed along with the map
    #       to XQ.Generator.generate/1
    move = XQ.Parser.parse(:axf, next_move)

    next_board_state =
      prev_board_states
      |> List.first()
      |> compute_next_state(move)

    [next_board_state | prev_board_states]
  end

  defp compute_next_state(prev_state, %Move{delta_rank: dr, next_file: nf} = move) do
    case Board.find_point(prev_state, move) do
      {old_point, index} ->
        # TODO: If delta_rank is nil, need to derive it based on the available
        #       move information
        delta_rank =
          case dr do
            nil ->
              move.sign * Point.fixed_delta_rank(move.ch, nf - old_point.file)

            v ->
              v
          end

        # Be consistent and use delta /or next for both rank and file
        new_point = Point.update(old_point, nf, delta_rank)
        updated_state = Board.update(prev_state, index, new_point)

        [new_point | updated_state]

      nil ->
        Logger.error("attempted to move a non-existent piece: #{inspect(move)}")
        prev_state
    end
  end
end
