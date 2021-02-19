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

  def generate(nil), do: [@starting_state] |> to_zero_indices()

  def generate(moves) do
    moves
    |> Enum.reduce([@starting_state], &generate_board_state/2)
    |> Enum.reverse()
    |> to_zero_indices()
  end

  defp to_zero_indices(states) do
    Enum.map(states, fn s -> Enum.map(s, &to_zero_index/1) end)
  end

  defp to_zero_index(piece) do
    piece |> Map.update!(:rank, &(&1 - 1)) |> Map.update!(:file, &(&1 - 1))
  end

  defp generate_board_state(next_move, prev_board_states) do
    exact_move = ~r/([a-z])([0-9])([+=-])([0-9])/i
    front_or_rear_move = ~r/([+-])([a-z])([+=-])([0-9])/i

    resolved_point =
      case Regex.run(exact_move, next_move) do
        nil ->
          nil

          case Regex.run(front_or_rear_move, next_move) do
            matches when is_list(matches) ->
              piece_mover(matches)

            nil ->
              raise RuntimeError, message: "invalid move notation"
          end

        matches ->
          piece_mover(matches)
      end

    next_board_state =
      prev_board_states
      |> List.first()
      |> update_point(resolved_point)

    [next_board_state | prev_board_states]
  end

  defp piece_mover([_match, abbrev, prev_file, dir, movement])
       when abbrev in ["P", "p", "C", "c", "R", "r"] do
    axis_mover(abbrev, prev_file, dir, movement)
  end

  defp piece_mover([_match, abbrev, prev_file, dir, next_file])
       when abbrev in ["B", "b", "N", "n", "A", "a", "K", "k"] do
    fixed_mover(abbrev, prev_file, dir, next_file)
  end

  # Pieces that lie on the same file
  defp piece_mover([_match, front_or_rear, abbrev, dir, movement])
       when front_or_rear in ["+", "-"] and
              abbrev in ["P", "p", "C", "c", "R", "r"] do
    axis_mover(abbrev, "-1", dir, movement, front_or_rear == "+")
  end

  defp piece_mover([_match, front_or_rear, abbrev, dir, next_file])
       when front_or_rear in ["+", "-"] and
              abbrev in ["B", "b", "N", "n", "A", "a", "K", "k"] do
    fixed_mover(abbrev, "-1", dir, next_file, front_or_rear == "+")
  end

  # Pieces that move vertically or horizontally
  defp axis_mover(abbrev, prev_file, dir, movement, is_front \\ true) do
    {
      ch,
      side,
      prev_file,
      abs_file_or_delta_rank
    } = parse_params(abbrev, prev_file, movement)

    file = calc_file(prev_file, side)
    sign = if side == @side_facing, do: -1, else: 1

    {next_file, diff_rank} =
      case dir do
        # Horizontal movement w/ absolute file
        "=" ->
          {calc_file(abs_file_or_delta_rank, side), 0}

        # Vertical movement w/ delta rank
        "-" ->
          {file, abs_file_or_delta_rank * -1}

        "+" ->
          {file, abs_file_or_delta_rank}
      end

    {ch, side, file, next_file, diff_rank * sign, is_front}
  end

  # Pieces that move both vertically and horizontally
  defp fixed_mover(abbrev, prev_file, dir, next_file, is_front \\ true) do
    {ch, side, prev_file, next_file} = parse_params(abbrev, prev_file, next_file)

    cond do
      prev_file == -1 or prev_file == 11 ->
        Logger.info("front or rear move")

      true ->
        nil
    end

    file = calc_file(prev_file, side)
    next_file = calc_file(next_file, side)

    sign = if side == @side_facing, do: -1, else: 1

    delta =
      case ch do
        :elephant -> 2
        :horse -> if abs(next_file - file) == 2, do: 1, else: 2
        _ -> 1
      end

    diff_rank =
      case dir do
        "+" -> sign
        "-" -> -sign
      end

    {ch, side, file, next_file, diff_rank * delta, is_front}
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
    |> Enum.filter(fn {p, _} -> p.file == file or file == -1 or file == 11 end)
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
      |> sort_front_rear_rank(side)

    {point, index} =
      if is_front == true,
        do: List.first(points_to_move),
        else: List.last(points_to_move)

    new_point =
      Map.merge(point, %{
        rank: point.rank + diff_rank,
        file: next_file
      })

    updated_board_state =
      board_state
      |> Enum.with_index()
      |> remove_original_piece(index)
      |> Enum.map(fn {p, _} -> p end)
      |> maybe_capture_piece(new_point)

    [new_point | updated_board_state]
  end

  defp sort_front_rear_rank(board_state, side) do
    Enum.sort(board_state, fn {a, _}, {b, _} ->
      if side == :red,
        do: a.rank < b.rank,
        else: a.rank > b.rank
    end)
  end

  defp remove_original_piece(board_state, orig_index) do
    Enum.filter(board_state, fn {_, i} -> i != orig_index end)
  end

  defp maybe_capture_piece(board_state, point) do
    Enum.filter(
      board_state,
      fn p -> p.file != point.file or p.rank != point.rank end
    )
  end
end
