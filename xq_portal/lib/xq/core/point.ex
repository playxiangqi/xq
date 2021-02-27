defmodule XQ.Core.Point do
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

  def can_capture(point, other),
    do:
      point.side != other.side and
        point.file == other.file and point.rank == other.rank

  def to_zero_index(point) do
    point |> Map.update!(:rank, &(&1 - 1)) |> Map.update!(:file, &(&1 - 1))
  end

  def by_rank(side, a, b) do
    if side == :red,
      do: a.rank < b.rank,
      else: a.rank > b.rank
  end

  def is_matching(point, other) do
    point.ch == other.ch and point.side == other.side and
      (point.file == other.file or is_front_or_rear(other))
  end

  # -1 for previous_file is a standin for front/rear move
  # In which case the resolved file will be -1 or 11 (depending on the side)
  defp is_front_or_rear(point) do
    point.file == -1 or point.file == 11
  end

  def update(point, next_file, diff_rank) do
    point
    |> Map.update!(:rank, &(&1 + diff_rank))
    # next_file of -1 indicates front/rear move where there is no file change
    |> Map.update!(:file, &if(next_file != -1, do: next_file, else: &1))
  end
end
