defmodule XQ.Parser.AXF do
  alias XQ.Core.{Point, Move}

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

    %Move{}
    |> derive_position(params)
    |> derive_piece(params)
    |> derive_sign(params)
    |> derive_file(params)
    |> derive_rank(params)
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

  def derive_position(%Move{} = move, %{pos: pos}),
    do: %{move | is_front: pos == "+"}

  def derive_position(move, _params), do: move

  def derive_piece(%Move{} = move, %{abbrev: abbrev}) do
    {ch, side} = Point.piece(abbrev)
    %{move | ch: ch, side: side}
  end

  def derive_sign(%Move{side: side} = move, %{dir: dir}),
    do: %{move | sign: Point.sign(side, dir)}

  def derive_file(%Move{side: side} = move, %{prev_file: nil, next_file: next}),
    do: %{move | next_file: Point.norm_file(next, side)}

  def derive_file(
        %Move{side: side} = move,
        %{prev_file: prev, next_file: next}
      ) do
    {prev, next} = {Point.norm_file(prev, side), Point.norm_file(next, side)}
    %{move | prev_file: prev, next_file: next, delta_file: next - prev}
  end

  def derive_file(
        %Move{side: side} = move,
        %{prev_file: prev, dir: dir, mvmt: mvmt}
      ) do
    prev = Point.norm_file(prev, side)
    next = maybe_horizontal(dir, mvmt, side, prev)
    # Axis piece notation carries direction / movement, no need for delta_file
    %{move | prev_file: prev, next_file: next}
  end

  def derive_rank(%Move{sign: sign} = move, %{mvmt: mvmt}),
    do: %{move | delta_rank: mvmt * sign}

  def derive_rank(%Move{delta_file: nil} = move, _params), do: move

  def derive_rank(%Move{ch: ch, sign: sign, delta_file: df} = move, _params),
    do: %{move | delta_rank: Point.fixed_delta_rank(ch, df, sign)}

  def derive_rank(move, _params), do: move

  defp maybe_horizontal(dir, value, side, default),
    do: if(dir == "=", do: Point.norm_file(value, side), else: default)

  defp safe_parse(match) do
    case Integer.parse(match) do
      {v, _} ->
        v

      :error ->
        match
    end
  end
end
