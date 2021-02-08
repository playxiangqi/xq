defmodule XQ.Board.State do
  require Logger

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

  @side_facing :red

  def generate(moves) do
    moves
    |> Enum.reduce([@starting_state], &generate_board_state/2)
    |> Enum.reverse()
    |> to_zero_indices()
  end

  def generate(nil), do: [@starting_state] |> to_zero_indices()

  defp to_zero_indices(states) do
    states
    |> Enum.map(fn s ->
      Enum.map(s, fn p ->
        %{
          ch: p.ch,
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
        nil ->
          nil

        # case Regex.run(front_or_rear_move, next_move) do
        #   matches when is_list(matches) ->
        #     piece_mover(matches)

        #   nil ->
        #     raise RuntimeError, message: "invalid move notation"
        # end

        matches ->
          piece_mover(matches)
      end

    case resolved_point do
      nil ->
        prev_board_states

      p ->
        next_board_state =
          prev_board_states
          |> List.first()
          |> update_point(p)

        [next_board_state | prev_board_states]
    end
  end

  # Pieces that move vertically or horizontally along axes
  defp piece_mover([_match, abbrev, prev_file, dir, abs_or_delta_file])
       when abbrev in ["P", "p", "C", "c", "R", "r"] do
    {
      ch,
      side,
      prev_file,
      abs_or_delta_file
    } = parse_params(abbrev, prev_file, abs_or_delta_file)

    file = calc_file(prev_file, side)
    sign = if side == @side_facing, do: -1, else: 1

    {next_file, diff_rank} =
      case dir do
        # Horizontal movement w/ absolute file
        "=" ->
          {calc_file(abs_or_delta_file, side), 0}

        # Vertical movement w/ delta file
        "-" ->
          {prev_file, abs_or_delta_file * -1}

        "+" ->
          {prev_file, abs_or_delta_file}
      end

    {ch, side, file, next_file, diff_rank * sign, true}
  end

  # Pieces that move both vertically and horizontally
  defp piece_mover([_match, abbrev, prev_file, dir, next_file])
       when abbrev in ["B", "b", "N", "n", "A", "a", "K", "k"] do
    {ch, side, prev_file, next_file} = parse_params(abbrev, prev_file, next_file)

    file = calc_file(prev_file, side)
    next_file = calc_file(next_file, side)

    sign = if side == @side_facing, do: -1, else: 1

    delta =
      case ch do
        :elephant -> 2
        :horse -> 1
        _ -> 1
      end

    diff_rank =
      case dir do
        "+" -> sign
        "-" -> -sign
      end

    {ch, side, file, next_file, diff_rank * delta, true}
  end

  defp parse_params(abbrev, prev, next) do
    {ch, side} = get_ch_and_side(abbrev)
    {prev, _} = Integer.parse(prev)
    {next, _} = Integer.parse(next)
    {ch, side, prev, next}
  end

  defp get_ch_and_side("A"), do: {:advisor, :red}
  defp get_ch_and_side("a"), do: {:advisor, :black}
  defp get_ch_and_side("P"), do: {:soldier, :red}
  defp get_ch_and_side("p"), do: {:soldier, :black}
  defp get_ch_and_side("C"), do: {:cannon, :red}
  defp get_ch_and_side("c"), do: {:cannon, :black}
  defp get_ch_and_side("N"), do: {:horse, :red}
  defp get_ch_and_side("n"), do: {:horse, :black}
  defp get_ch_and_side("R"), do: {:chariot, :red}
  defp get_ch_and_side("r"), do: {:chariot, :black}
  defp get_ch_and_side("B"), do: {:elephant, :red}
  defp get_ch_and_side("b"), do: {:elephant, :black}
  defp get_ch_and_side("K"), do: {:general, :red}
  defp get_ch_and_side("k"), do: {:general, :black}

  defp calc_file(prev, side) when side == @side_facing, do: 10 - prev
  defp calc_file(prev, _side), do: prev

  defp get_matching_points(board_state, ch, side, file) do
    board_state
    |> Enum.filter(fn {p, _} -> p.ch == ch and p.side == side end)
    |> Enum.filter(fn {p, _} -> p.file == file end)
  end

  defp update_point(board_state, {
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

    Logger.info("points_to_move: #{inspect(points_to_move)}")

    # |> Enum.sort(fn {a, _}, {b, _} ->
    #   case side do
    #     :red -> a.rank < b.rank
    #     _ -> b.rank > a.rank
    #   end
    # end)

    # |> Enum.filter(fn {p, _} ->
    #   case file do
    #     f -> p[:file] == file
    #     nil -> true
    #   end
    # end)

    case points_to_move do
      [] ->
        board_state

      points ->
        {point, index} =
          if is_front == true,
            do: List.first(points),
            else: List.last(points)

        Logger.info("exact_point: #{inspect(point)}, index: #{index}")

        new_point = Map.merge(point, %{rank: point.rank + diff_rank, file: next_file})

        Logger.info("new_point: #{inspect(new_point)}")

        updated_board_state =
          board_state
          |> Enum.with_index()
          |> Enum.filter(fn {_, i} -> i != index end)
          |> Enum.map(fn {p, _} -> p end)

        Logger.info("updated_board_state: #{inspect(updated_board_state)}")

        [new_point | updated_board_state]
    end
  end
end
