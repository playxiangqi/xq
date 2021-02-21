defmodule XQ.Core.Point do
  @type t :: %{
          side: :red | :black,
          rank: integer(),
          file: integer()
        }

  @max_file 10
  @side_facing :red

  def norm_file(prev, side) when side == @side_facing, do: @max_file - prev
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
end
