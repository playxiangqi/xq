defmodule XQ.Parser.Notation do
  defstruct direction: "+",
            delta: nil,
            prev_file: nil,
            next_file: nil,
            is_front: true

  @type t :: %__MODULE__{
          direction: String.t(),
          delta: integer() | nil,
          prev_file: integer() | nil,
          next_file: integer() | nil,
          is_front: boolean()
        }
end
