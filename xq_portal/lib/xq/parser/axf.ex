defmodule XQ.Parser.AXF do
  alias XQ.Parser.Notation

  defguardp is_axis(p) when p in ~w(P p C c R r K k)
  defguardp is_constrained(p) when p in ~w(B b N n A a)
  defguardp is_positional(d) when d in ~w(+ -)

  def parse(notation) do
    exact = ~r/([a-z])([0-9])([+=-])([0-9])/i
    positional = ~r/([+-])([a-z])([+=-])([0-9])/i

    matches =
      Regex.run(exact, notation) || Regex.run(positional, notation) ||
        raise RuntimeError, message: "invalid move notation"

    normalize(matches)
  end

  @doc """

  ## Parameters


  """
  def normalize([_, abbrev, prev_file, direction, movement])
      when is_axis(abbrev) do
    %Notation{
      direction: direction,
      prev_file: prev_file
    }
  end

  def normalize([_, position, abbrev, direction, movement])
      when is_axis(abbrev) and is_positional(position) do
    %Notation{
      direction: direction,
      prev_file: nil
    }
  end

  def normalize(_), do: raise(RuntimeError, message: "invalid AXF notation")
end
