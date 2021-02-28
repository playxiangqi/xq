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
    |> derive_file(params)
    |> derive_rank(params)
  end

  def derive_piece(%MoveDetails{} = details, [pos, abbrev, _, _])
      when is_positional(pos),
      do: do_derive_piece(details, abbrev)

  def derive_piece(%MoveDetails{} = details, [abbrev, _, _, _]),
    do: do_derive_piece(details, abbrev)

  defp do_derive_piece(details, abbrev) do
    {ch, side} = Point.piece(abbrev)
    %{details | ch: ch, side: side}
  end

  def derive_sign(%MoveDetails{side: side} = details, [_, _, dir, _]),
    do: %{details | sign: Point.sign(side, dir)}

  def derive_position(%MoveDetails{} = details, [pos, _, _, _])
      when is_positional(pos),
      do: %{details | is_front: pos == "+"}

  def derive_position(details, _params), do: details

  def derive_file(%MoveDetails{side: side} = details, [pos, abbrev, dir, mvmt])
      when is_positional(pos) and is_axis(abbrev),
      do: %{details | next_file: maybe_horizontal(dir, mvmt, side)}

  def derive_file(%MoveDetails{side: side} = details, [abbrev, prev, dir, mvmt])
      when is_axis(abbrev) do
    prev = Point.norm_file(prev, side)
    next = maybe_horizontal(dir, mvmt, side, prev)
    %{details | prev_file: prev, next_file: next, delta_file: next - prev}
  end

  def derive_file(%MoveDetails{side: side} = details, [pos, abbrev, _, next])
      when is_positional(pos) and is_fixed(abbrev),
      do: %{details | next_file: Point.norm_file(next, side)}

  def derive_file(%MoveDetails{side: side} = details, [abbrev, prev, _, next])
      when is_fixed(abbrev) do
    {prev, next} = {Point.norm_file(prev, side), Point.norm_file(next, side)}
    %{details | prev_file: prev, next_file: next, delta_file: next - prev}
  end

  def derive_rank(%MoveDetails{sign: sign} = details, [pos, abbrev, _, mvmt])
      when is_positional(pos) and is_axis(abbrev),
      do: %{details | delta_rank: mvmt * sign}

  def derive_rank(%MoveDetails{sign: sign} = details, [abbrev, _, _, mvmt])
      when is_axis(abbrev),
      do: %{details | delta_rank: mvmt * sign}

  def derive_rank(
        %MoveDetails{
          ch: ch,
          sign: sign,
          delta_file: d
        } = details,
        [pos, abbrev, _, _]
      )
      when is_positional(pos) and is_fixed(abbrev),
      do: %{details | delta_rank: fixed_delta(ch, d) * sign}

  def derive_rank(
        %MoveDetails{
          ch: ch,
          sign: sign,
          delta_file: d
        } = details,
        [abbrev, _, _, _]
      )
      when is_fixed(abbrev),
      do: %{details | delta_rank: fixed_delta(ch, d) * sign}

  defp safe_parse(match) do
    case Integer.parse(match) do
      {v, _} ->
        v

      :error ->
        match
    end
  end

  defp maybe_horizontal(dir, value, side, default \\ nil),
    do: if(dir == "=", do: Point.norm_file(value, side), else: default)

  defp fixed_delta(:elephant, _), do: 2
  defp fixed_delta(:horse, delta_file), do: if(abs(delta_file) == 2, do: 1, else: 2)
  defp fixed_delta(_, _), do: 1
end
