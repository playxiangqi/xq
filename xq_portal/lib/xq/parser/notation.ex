defmodule XQ.Parser.Notation do
  defstruct ~w(direction delta prev_file next_file is_front)a

  @type t :: %__MODULE__{
          direction: String.t(),
          delta: integer() | nil,
          prev_file: integer() | nil,
          next_file: integer() | nil,
          is_front: boolean() | nil
        }

  def default do
    %__MODULE__{
      direction: "+",
      delta: nil,
      prev_file: nil,
      next_file: nil,
      is_front: nil
    }
  end
end
