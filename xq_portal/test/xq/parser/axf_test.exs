defmodule XQ.Parser.AXFTest do
  use ExUnit.Case

  alias XQ.Core.Move
  alias XQ.Parser.AXF

  @axis ~w(P p C c R r K k)
  @fixed ~w(B b N n A a)
  @direction ~w(+ = -)
  @position ~w(+ -)
  @range 0..9
  @default %Move{}

  test "Parametrize exact axis notation" do
    matches = Enum.map([@axis, @range, @direction, @range], &Enum.random(&1))
    params = AXF.parametrize(matches)

    assert Map.has_key?(params, :abbrev)
    assert Map.has_key?(params, :prev_file)
    assert Map.has_key?(params, :dir)
    assert Map.has_key?(params, :mvmt)
  end

  test "Parametrize positional axis notation" do
    matches = Enum.map([@position, @axis, @direction, @range], &Enum.random(&1))
    params = AXF.parametrize(matches)

    assert Map.has_key?(params, :pos)
    assert Map.has_key?(params, :abbrev)
    assert params[:prev_file] == nil
    assert Map.has_key?(params, :dir)
    assert Map.has_key?(params, :mvmt)
  end

  test "Parametrize exact fixed notation" do
    matches = Enum.map([@fixed, @range, @direction, @range], &Enum.random(&1))
    params = AXF.parametrize(matches)

    assert Map.has_key?(params, :abbrev)
    assert Map.has_key?(params, :prev_file)
    assert Map.has_key?(params, :dir)
    assert Map.has_key?(params, :next_file)
  end

  test "Parametrize positional fixed notation" do
    matches = Enum.map([@position, @fixed, @direction, @range], &Enum.random(&1))
    params = AXF.parametrize(matches)

    assert Map.has_key?(params, :pos)
    assert Map.has_key?(params, :abbrev)
    assert params[:prev_file] == nil
    assert Map.has_key?(params, :dir)
    assert Map.has_key?(params, :next_file)
  end

  test "Derive position" do
    wrapper = &AXF.derive_position(@default, %{pos: &1})

    assert wrapper.("+") == %Move{is_front: true}
    assert wrapper.("-") == %Move{is_front: false}
    assert AXF.derive_position(@default, %{}) == @default
  end
end
