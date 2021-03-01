defmodule XQ.Core.Point do
  require Logger

  @type t :: %{
          ch: atom(),
          side: :red | :black,
          rank: integer(),
          file: integer()
        }

  @max_file 10
  @side_facing :red

  def norm_file(prev, side) when side == @side_facing and not is_nil(prev),
    do: @max_file - prev

  def norm_file(prev, _side), do: prev

  def sign(side, "+"), do: sign(side)
  def sign(side, "-"), do: -1 * sign(side)
  def sign(_side, "="), do: 0

  def sign(@side_facing), do: -1
  def sign(_side), do: 1

  def piece("A"), do: {:advisor, :red}
  def piece("a"), do: {:advisor, :black}
  def piece("P"), do: {:soldier, :red}
  def piece("p"), do: {:soldier, :black}
  def piece("C"), do: {:cannon, :red}
  def piece("c"), do: {:cannon, :black}
  def piece("N"), do: {:horse, :red}
  def piece("n"), do: {:horse, :black}
  def piece("R"), do: {:chariot, :red}
  def piece("r"), do: {:chariot, :black}
  def piece("B"), do: {:elephant, :red}
  def piece("b"), do: {:elephant, :black}
  def piece("K"), do: {:general, :red}
  def piece("k"), do: {:general, :black}

  def fixed_delta_rank(ch, df, sign), do: sign * do_fixed_delta_rank(ch, df)
  defp do_fixed_delta_rank(:elephant, _), do: 2
  defp do_fixed_delta_rank(:horse, df), do: if(abs(df) == 2, do: 1, else: 2)
  defp do_fixed_delta_rank(_, _), do: 1

  def can_capture(point, other),
    do:
      point.side != other.side and
        point.file == other.file and point.rank == other.rank

  def to_zero_index(point) do
    # Logger.info("#{inspect(point)}")

    point |> Map.update!(:rank, &(&1 - 1)) |> Map.update!(:file, &(&1 - 1))
  end

  def by_rank(side, a, b) do
    if side == :red,
      do: a.rank < b.rank,
      else: a.rank > b.rank
  end

  def is_matching(point, other) do
    point.ch == other.ch and point.side == other.side and
      (point.file == other.file or multiple_on_same_file(other))
  end

  defp multiple_on_same_file(%{file: nil}), do: true
  defp multiple_on_same_file(%{file: _}), do: false

  def update(point, next_file, diff_rank) do
    point
    |> Map.update!(:rank, &(&1 + diff_rank))
    # next_file of nil indicates front/rear move where there is no file change
    |> Map.update!(:file, &if(not is_nil(next_file), do: next_file, else: &1))
  end
end
