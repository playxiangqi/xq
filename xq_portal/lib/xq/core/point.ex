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

  # TODO: move sign/2 to AXF specific
  def sign(side, "+"), do: sign(side)
  def sign(side, "-"), do: -1 * sign(side)
  def sign(_side, "="), do: 0

  def sign(@side_facing), do: -1
  def sign(_side), do: 1

  # TODO: piece/1 to AXF specific
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

  def fixed_delta_rank(ch, df, sign), do: sign * delta_rank(ch, df)
  defp delta_rank(:elephant, _), do: 2
  defp delta_rank(:horse, df), do: if(abs(df) == 2, do: 1, else: 2)
  defp delta_rank(_, _), do: 1

  def can_capture(point, other),
    do:
      point.side != other.side and
        point.file == other.file and point.rank == other.rank

  def to_zero_index(points) when is_list(points) do
    Enum.map(points, &to_zero_index/1)
  end

  def to_zero_index(nil), do: nil

  def to_zero_index(point) do
    point |> Map.update!(:rank, &(&1 - 1)) |> Map.update!(:file, &(&1 - 1))
  end

  def by_rank(a, b), do: a.rank < b.rank

  def by_rank(:red, a, b), do: by_rank(a, b)
  def by_rank(:black, a, b), do: not by_rank(a, b)

  def by_file(a, b), do: a.file < b.file
  def by_file(:red, a, b), do: not by_file(a, b)
  def by_file(:black, a, b), do: by_file(a, b)

  def is_matching(point, other) do
    point.ch == other.ch and point.side == other.side and
      (point.file == other.file or multiple_on_same_file(other))
  end

  defp multiple_on_same_file(%{file: nil}), do: true
  defp multiple_on_same_file(%{file: _}), do: false
end
