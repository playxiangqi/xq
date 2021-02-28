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
      |> parametrize()

    %MoveDetails{}
    |> derive_position(params)
    |> derive_piece(params)
    |> derive_sign(params)
    |> derive_file(params)
    |> derive_rank()
  end

  def parametrize([pos, abbrev, dir, mvmt])
      when is_positional(pos) and is_axis(abbrev),
      do: %{pos: pos, abbrev: abbrev, prev_file: nil, dir: dir, mvmt: mvmt}

  def parametrize([abbrev, prev_file, dir, mvmt])
      when is_axis(abbrev),
      do: %{abbrev: abbrev, prev_file: prev_file, dir: dir, mvmt: mvmt}

  def parametrize([pos, abbrev, dir, next_file])
      when is_positional(pos) and is_fixed(abbrev),
      do: %{pos: pos, abbrev: abbrev, prev_file: nil, dir: dir, next_file: next_file}

  def parametrize([abbrev, prev_file, dir, next_file])
      when is_fixed(abbrev),
      do: %{abbrev: abbrev, prev_file: prev_file, dir: dir, next_file: next_file}

  def derive_position(%MoveDetails{} = details, %{pos: pos}),
    do: %{details | is_front: pos == "+"}

  def derive_position(details, _params), do: details

  def derive_piece(%MoveDetails{} = details, %{abbrev: abbrev}) do
    {ch, side} = Point.piece(abbrev)
    %{details | ch: ch, side: side}
  end

  def derive_sign(%MoveDetails{side: side} = details, %{dir: dir}),
    do: %{details | sign: Point.sign(side, dir)}

  def derive_file(
        %MoveDetails{side: side} = details,
        %{prev_file: prev, dir: dir, mvmt: mvmt}
      ) do
    prev = Point.norm_file(prev, side)
    next = maybe_horizontal(dir, mvmt, side, prev)
    %{details | prev_file: prev, next_file: next, delta_file: next - prev}
  end

  def derive_file(
        %MoveDetails{side: side} = details,
        %{prev_file: nil, next_file: next}
      ),
      do: %{details | next_file: Point.norm_file(next, side)}

  def derive_file(
        %MoveDetails{side: side} = details,
        %{prev_file: prev, next_file: next}
      ) do
    {prev, next} = {Point.norm_file(prev, side), Point.norm_file(next, side)}
    %{details | prev_file: prev, next_file: next, delta_file: next - prev}
  end

  def derive_rank(%MoveDetails{sign: sign} = details, %{mvmt: mvmt}),
    do: %{details | delta_rank: mvmt * sign}

  def derive_rank(%MoveDetails{ch: ch, sign: sign, delta_file: df} = details),
    do: %{details | delta_rank: fixed_delta(ch, df) * sign}

  def derive_rank(details), do: details

  defp maybe_horizontal(dir, value, side, default),
    do: if(dir == "=", do: Point.norm_file(value, side), else: default)

  defp fixed_delta(:elephant, _), do: 2
  defp fixed_delta(:horse, delta_file), do: if(abs(delta_file) == 2, do: 1, else: 2)
  defp fixed_delta(_, _), do: 1

  defp safe_parse(match) do
    case Integer.parse(match) do
      {v, _} ->
        v

      :error ->
        match
    end
  end
end
