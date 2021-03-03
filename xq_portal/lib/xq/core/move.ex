defmodule XQ.Core.Move do
  alias XQ.Core.Point

  defstruct ch: :soldier,
            side: :red,
            sign: 1,
            prev_file: nil,
            next_file: nil,
            delta_file: nil,
            prev_rank: nil,
            next_rank: nil,
            delta_rank: nil,
            is_front: true

  @type t :: %__MODULE__{
          ch: atom(),
          side: :red | :black,
          sign: integer(),
          prev_file: integer() | nil,
          next_file: integer() | nil,
          delta_file: integer() | nil,
          prev_rank: integer() | nil,
          next_rank: integer() | nil,
          delta_rank: integer() | nil,
          is_front: boolean()
        }

  def next(%__MODULE__{next_file: nf, delta_rank: dr} = move, old_point) do
    delta_rank =
      if is_nil(dr),
        do: Point.fixed_delta_rank(move.ch, nf - old_point.file, move.sign),
        else: dr

    file =
      if is_nil(nf),
        do: old_point.file,
        else: nf

    %{old_point | rank: old_point.rank + delta_rank, file: file}
  end
end
