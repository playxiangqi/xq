defmodule XQ.Core.Move do
  alias XQ.Core.Point

  defstruct ~w(ch side prev_file next_file diff_rank is_front)a

  # TODO: Move this to a parser module that provides inputs to this mover module
  @type parsed :: %{
          direction: String.t(),
          delta: integer() | nil,
          prev_file: integer() | nil,
          next_file: integer() | nil,
          is_front: boolean() | nil
        }

  @type t :: %__MODULE__{
          ch: atom(),
          side: :red | :black,
          prev_file: integer() | nil,
          next_file: integer() | nil,
          diff_rank: integer() | nil,
          is_front: boolean() | nil
        }

  defguardp is_axis_piece(letter) when letter in ~w(P p C c R r K k)
  defguardp is_fixed_piece(letter) when letter in ~w(B b N n A a)
  defguardp is_positional(c) when c in ~w(+ -)

  # TODO: Eventually abstract to a number of different notation parsers
  #       that generate a uniform move struct w/ as much point info as possible
  def resolve(notation) do
    exact_move = ~r/([a-z])([0-9])([+=-])([0-9])/i
    front_or_rear_move = ~r/([+-])([a-z])([+=-])([0-9])/i

    matches =
      Regex.run(exact_move, notation) ||
        Regex.run(front_or_rear_move, notation) ||
        raise RuntimeError, message: "invalid move notation"

    piece_mover(matches)
  end

  defp piece_mover([_, letter, prev_file, dir, movement])
       when is_axis_piece(letter) do
    axis_mover(letter, prev_file, dir, movement)
  end

  defp piece_mover([_, letter, prev_file, dir, next_file])
       when is_fixed_piece(letter) do
    fixed_mover(letter, prev_file, dir, next_file)
  end

  # Pieces that lie on the same file
  defp piece_mover([_, front_or_rear, letter, dir, movement])
       when is_positional(front_or_rear) and is_axis_piece(letter) do
    axis_mover(letter, "-1", dir, movement, front_or_rear == "+")
  end

  defp piece_mover([_, front_or_rear, letter, dir, next_file])
       when is_positional(front_or_rear) and is_fixed_piece(letter) do
    fixed_mover(letter, "-1", dir, next_file, front_or_rear == "+")
  end

  # Pieces that move vertically or horizontally
  defp axis_mover(letter, prev_file, dir, movement, is_front \\ true) do
    {
      ch,
      side,
      prev_file,
      abs_file_or_delta_rank
    } = parse_params(letter, prev_file, movement)

    file = Point.norm_file(prev_file, side)
    sign = Point.sign(side)

    {next_file, diff_rank} =
      case dir do
        # Horizontal movement w/ absolute file
        "=" ->
          {Point.norm_file(abs_file_or_delta_rank, side), 0}

        # Vertical movement w/ delta rank
        "-" ->
          {file, abs_file_or_delta_rank * -1}

        "+" ->
          {file, abs_file_or_delta_rank}
      end

    {ch, side, file, next_file, diff_rank * sign, is_front}
  end

  # Pieces that move both vertically and horizontally
  defp fixed_mover(letter, prev_file, dir, next_file, is_front \\ true) do
    {ch, side, prev_file, next_file} = parse_params(letter, prev_file, next_file)

    file = Point.norm_file(prev_file, side)
    next_file = Point.norm_file(next_file, side)

    sign = Point.sign(side)

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
    {ch, side} = Point.piece(abbrev)
    {prev, _} = Integer.parse(prev)
    {next, _} = Integer.parse(next)
    {ch, side, prev, next}
  end
end
