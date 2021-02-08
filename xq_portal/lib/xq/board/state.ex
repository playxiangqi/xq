defmodule XQ.Board.State do
  @starting_state [
    %{piece: :chariot, side: :black, rank: 1, file: 1},
    %{piece: :horse, side: :black, rank: 1, file: 2},
    %{piece: :elephant, side: :black, rank: 1, file: 3},
    %{piece: :advisor, side: :black, rank: 1, file: 4},
    %{piece: :general, side: :black, rank: 1, file: 5},
    %{piece: :advisor, side: :black, rank: 1, file: 6},
    %{piece: :elephant, side: :black, rank: 1, file: 7},
    %{piece: :horse, side: :black, rank: 1, file: 8},
    %{piece: :chariot, side: :black, rank: 1, file: 9},
    %{piece: :cannon, side: :black, rank: 3, file: 2},
    %{piece: :cannon, side: :black, rank: 3, file: 8},
    %{piece: :soldier, side: :black, rank: 4, file: 1},
    %{piece: :soldier, side: :black, rank: 4, file: 3},
    %{piece: :soldier, side: :black, rank: 4, file: 5},
    %{piece: :soldier, side: :black, rank: 4, file: 7},
    %{piece: :soldier, side: :black, rank: 4, file: 9},
    %{piece: :soldier, side: :red, rank: 7, file: 1},
    %{piece: :soldier, side: :red, rank: 7, file: 3},
    %{piece: :soldier, side: :red, rank: 7, file: 5},
    %{piece: :soldier, side: :red, rank: 7, file: 7},
    %{piece: :soldier, side: :red, rank: 7, file: 9},
    %{piece: :cannon, side: :red, rank: 8, file: 2},
    %{piece: :cannon, side: :red, rank: 8, file: 8},
    %{piece: :chariot, side: :red, rank: 10, file: 1},
    %{piece: :horse, side: :red, rank: 10, file: 2},
    %{piece: :elephant, side: :red, rank: 10, file: 3},
    %{piece: :advisor, side: :red, rank: 10, file: 4},
    %{piece: :general, side: :red, rank: 10, file: 5},
    %{piece: :advisor, side: :red, rank: 10, file: 6},
    %{piece: :elephant, side: :red, rank: 10, file: 7},
    %{piece: :horse, side: :red, rank: 10, file: 8},
    %{piece: :chariot, side: :red, rank: 10, file: 9}
  ]

  @side_facing :red

  def generate(moves) do
    moves
    |> Enum.reduce([@starting_state], &generate_board_state/2)
    |> to_zero_indices()
  end

  def generate(nil), do: [@starting_state] |> to_zero_indices()

  defp to_zero_indices(states) do
    states
    |> Enum.each(fn s ->
      Enum.map(s, fn p ->
        %{
          piece: p.piece,
          side: p.side,
          rank: p.rank - 1,
          file: p.file - 1
        }
      end)
    end)
  end

  defp generate_board_state(next_move, prev_board_states) do
    exact_move = ~r/([a-z])([0-9])([+=-])([0-9])/i
    front_or_rear_move = ~r/([+-])([a-z])([+=-])([0-9])/i

    resolved_point =
      case Regex.run(exact_move, next_move) do
        matches when is_list(matches) ->
          default_mover(matches)

        nil ->
          case Regex.run(front_or_rear_move, next_move) do
            matches when is_list(matches) ->
              default_mover(matches)

            nil ->
              raise RuntimeError, message: "invalid move notation"
          end
      end

    next_board_state =
      prev_board_states
      |> List.first()
      |> update_point(resolved_point)

    [next_board_state | prev_board_states]
  end

  defp default_mover([abbrev, prev_file, next_file, direction]) do
    {piece, side} = get_piece_and_side(abbrev)
    file = calc_file(prev_file, side)
    next_file = calc_file(next_file, side)

    sign =
      case direction do
        "+" -> -1
        _ -> -1
      end

    diff_rank = sign

    {piece, side, file, next_file, diff_rank, true}
  end

  defp update_point(board_state, {
         piece,
         side,
         file,
         next_file,
         diff_rank,
         is_front
       }) do
    points_to_move =
      board_state
      |> Enum.with_index()
      |> Enum.filter(fn {p, _} -> p.piece == piece and p.side == side end)
      |> Enum.sort_by(fn {{a, _}, {b, _}} ->
        case side do
          :red -> a.rank - b.rank
          _ -> b.rank - a.rank
        end
      end)

    # |> Enum.filter(fn {p, _} ->
    #   case file do
    #     f -> p[:file] == file
    #     nil -> true
    #   end
    # end)

    {point, index} =
      if is_front == true,
        do: List.first(points_to_move),
        else: List.last(points_to_move)

    new_point = Map.merge(point, %{rank: point.rank + diff_rank, file: next_file})

    updated_board_state =
      board_state
      |> Enum.with_index()
      |> Enum.filter(fn {_, i} -> i != index end)

    [new_point, updated_board_state]
  end

  defp get_piece_and_side("A"), do: {:advisor, :red}
  defp get_piece_and_side("a"), do: {:advisor, :black}
  defp get_piece_and_side("P"), do: {:soldier, :red}
  defp get_piece_and_side("p"), do: {:soldier, :black}
  defp get_piece_and_side("C"), do: {:cannon, :red}
  defp get_piece_and_side("c"), do: {:cannon, :black}
  defp get_piece_and_side("N"), do: {:horse, :red}
  defp get_piece_and_side("n"), do: {:horse, :black}
  defp get_piece_and_side("R"), do: {:chariot, :red}
  defp get_piece_and_side("r"), do: {:chariot, :black}
  defp get_piece_and_side("B"), do: {:elephant, :red}
  defp get_piece_and_side("b"), do: {:elephant, :black}
  defp get_piece_and_side("K"), do: {:general, :red}
  defp get_piece_and_side("k"), do: {:general, :black}

  defp calc_file(prev, side) when side == @side_facing, do: 10 - prev
  defp calc_file(prev, side), do: prev
end
