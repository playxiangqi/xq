defmodule XQ.Generator do
  require Logger

  alias XQ.Core.{Board, Move, Point}

  @starting_state %Board{
    state: [
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
    ],
    prev_point: nil,
    next_point: nil
  }

  # TODO: Can turn this to match :moves vs. :board
  #       to determine move notation, e.g. FEN/PGN
  #       And also determine if a single or multiple boards need to be generated
  #       where the latter requires move generation
  def generate(%{id: id, moves: moves}) do
    Logger.info("id: #{id}")
    Logger.info("moves: #{inspect(moves, limit: :infinity)}")

    # TODO: Currently hard-coded, but notation should be passed in input
    moves
    |> Enum.map(&XQ.Parser.parse(:axf, &1))
    |> Enum.reduce([@starting_state], &generate_board/2)
    |> Enum.reverse()
    |> to_zero_indices()
  end

  def generate(_), do: [@starting_state] |> to_zero_indices()

  defp to_zero_indices(boards) do
    Logger.info("boards: #{inspect(boards)}")

    Enum.map(boards, fn %Board{state: state} = board ->
      %{board | state: Enum.map(state, &Point.to_zero_index/1)}
    end)
  end

  defp generate_board(next_move, prev_boards) do
    next_board =
      prev_boards
      |> List.first()
      |> compute_next_state(next_move)

    [next_board | prev_boards]
  end

  defp compute_next_state(%{state: prev_state}, %Move{} = move) do
    # TODO: Can lift all board-level funcs to generate_board func
    case Board.find_point(prev_state, move) do
      {prev_point, index} ->
        next_point = Move.next(move, prev_point)
        updated_state = Board.update(prev_state, next_point, index)

        %Board{
          state: [next_point | updated_state],
          prev_point: prev_point,
          next_point: next_point
        }

      nil ->
        raise RuntimeError,
          message: "attempted to move a non-existent piece: #{inspect(move)}"
    end
  end
end
