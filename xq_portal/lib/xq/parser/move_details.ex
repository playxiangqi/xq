defmodule XQ.Parser.MoveDetails do
  defstruct ch: :soldier,
            side: :red,
            sign: 1,
            delta: nil,
            prev_file: nil,
            next_file: nil,
            is_front: true

  @type t :: %__MODULE__{
          ch: atom(),
          side: :red | :black,
          sign: integer(),
          delta: integer() | nil,
          prev_file: integer() | nil,
          next_file: integer() | nil,
          is_front: boolean()
        }
end
