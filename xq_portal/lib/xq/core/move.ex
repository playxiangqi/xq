defmodule XQ.Core.Move do
  defstruct ~w(kind letter direction delta prev_file next_file is_front)a

  @type t :: %__MODULE__{
          kind: :axis | :fixed,
          letter: String.t(),
          direction: String.t(),
          delta: integer() | nil,
          prev_file: integer() | nil,
          next_file: integer() | nil,
          is_front: boolean() | nil
        }

  defguardp is_axis_piece(letter) when letter in ~w(P p C c R r K k)
  defguardp is_fixed_piece(letter) when letter in ~w(B b N n A a)
  defguardp is_positional(c) when c in ~w(+ -)

  def resolve(notation) do
    exact_move = ~r/([a-z])([0-9])([+=-])([0-9])/i
    front_or_rear_move = ~r/([+-])([a-z])([+=-])([0-9])/i

    matches =
      Regex.run(exact_move, notation) ||
        Regex.run(front_or_rear_move, notation) ||
        raise RuntimeError, message: "invalid move notation"

    to_move(matches)
  end

  def move(%__MODULE__{kind: :axis} = move) do
  end

  def move(%__MODULE__{kind: :fixed} = move) do
  end

  # TODO: Can be further coalesced into fewer loc
  defp to_move([_match, position, letter, direction, delta])
       when is_positional(position) or is_axis_piece(letter) do
    %__MODULE__{
      kind: :axis,
      letter: letter,
      direction: direction,
      delta: delta,
      prev_file: nil,
      next_file: nil,
      is_front: position == "+"
    }
  end

  defp to_move([_match, letter, prev_file, direction, delta])
       when is_axis_piece(letter) do
    %__MODULE__{
      kind: :axis,
      letter: letter,
      direction: direction,
      delta: delta,
      prev_file: prev_file,
      next_file: nil,
      is_front: nil
    }
  end

  defp to_move([_match, position, letter, direction, next_file])
       when is_positional(position) or is_fixed_piece(letter) do
    %__MODULE__{
      kind: :fixed,
      letter: letter,
      direction: direction,
      delta: nil,
      prev_file: nil,
      next_file: next_file,
      is_front: position == "+"
    }
  end

  defp to_move([_match, letter, prev_file, direction, next_file])
       when is_fixed_piece(letter) do
    %__MODULE__{
      kind: :fixed,
      letter: letter,
      direction: direction,
      delta: nil,
      prev_file: prev_file,
      next_file: next_file,
      is_front: nil
    }
  end
end
