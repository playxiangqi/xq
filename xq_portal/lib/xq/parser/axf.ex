defmodule XQ.Parser.AXF do
  alias XQ.Core.{Point}
  alias XQ.Parser.MoveDetails

  defguardp is_axis(p) when p in ~w(P p C c R r K k)
  defguardp is_fixed(p) when p in ~w(B b N n A a)
  defguardp is_positional(d) when d in ~w(+ -)

  def parse(notation) do
    exact = ~r/([a-z])([0-9])([+=-])([0-9])/i
    positional = ~r/([+-])([a-z])([+=-])([0-9])/i

    matches =
      Regex.run(exact, notation) || Regex.run(positional, notation) ||
        raise RuntimeError, message: "invalid move notation"

    params =
      matches
      |> Enum.slice(1..-1)
      |> Enum.map(&safe_parse/1)

    %MoveDetails{}
    |> derive_piece(params)
    |> derive_sign(params)
    |> derive_position(params)
  end

  def derive_piece(%MoveDetails{} = details, [pos, abbrev, _, _])
      when is_positional(pos) do
    do_derive_piece(details, abbrev)
  end

  def derive_piece(%MoveDetails{} = details, [abbrev, _, _, _]) do
    do_derive_piece(details, abbrev)
  end

  defp do_derive_piece(details, abbrev) do
    {ch, side} = Point.piece(abbrev)
    %{details | ch: ch, side: side}
  end

  def derive_sign(%MoveDetails{side: side} = details, [_, _, direction, _]) do
    %{details | sign: Point.sign(side, direction)}
  end

  def derive_position(%MoveDetails{} = details, [pos, _, _, _])
      when is_positional(pos) do
    %{details | is_front: pos == "+"}
  end

  def derive_position(details, _params), do: details

  defp safe_parse(match) do
    case Integer.parse(match) do
      {v, _} ->
        v

      :error ->
        match
    end
  end
end
