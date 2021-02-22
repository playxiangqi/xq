defmodule XQ.Parser.AXF do
  alias XQ.Parser.Notation

  defguardp is_axis_piece(letter) when letter in ~w(P p C c R r K k)
  defguardp is_fixed_piece(letter) when letter in ~w(B b N n A a)
  defguardp is_positional(c) when c in ~w(+ -)

  def parse(move) do
    exact_notation = ~r/([a-z])([0-9])([+=-])([0-9])/i
    positional_notation = ~r/([+-])([a-z])([+=-])([0-9])/i

    matches =
      Regex.run(exact_notation, move) ||
        Regex.run(positional_notation, move) ||
        raise RuntimeError, message: "invalid move notation"
  end

  defp from_matches([_, letter, prev_file, direction, movement])
       when is_axis_piece(letter) do
    Map.merge(Notation.default(), %{
      direction: direction,
      prev_file: prev_file
    })
  end
end
