defmodule XQ.Parser.MoveDetails do
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
end
