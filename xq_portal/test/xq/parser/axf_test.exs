defmodule XQ.Parser.AXFTest do
  use ExUnit.Case, async: true

  alias XQ.Core.Move
  alias XQ.Parser.AXF

  @axis ~w(P p C c R r K k)
  @fixed ~w(B b N n A a)
  @direction ~w(+ = -)
  @position ~w(+ -)
  @range 0..9
  @default %Move{}

  describe "AXF.parametrize/1" do
    test "exact axis notation" do
      # TODO: Move to fixture
      params =
        [@axis, @range, @direction, @range]
        |> Enum.map(&Enum.random/1)
        |> AXF.parametrize()

      assert Map.has_key?(params, :abbrev)
      assert Map.has_key?(params, :prev_file)
      assert Map.has_key?(params, :dir)
      assert Map.has_key?(params, :mvmt)
    end

    test "positional axis notation" do
      params =
        [@position, @axis, @direction, @range]
        |> Enum.map(&Enum.random/1)
        |> AXF.parametrize()

      assert Map.has_key?(params, :pos)
      assert Map.has_key?(params, :abbrev)
      assert params[:prev_file] == nil
      assert Map.has_key?(params, :dir)
      assert Map.has_key?(params, :mvmt)
    end

    test "exact fixed notation" do
      params =
        [@fixed, @range, @direction, @range]
        |> Enum.map(&Enum.random/1)
        |> AXF.parametrize()

      assert Map.has_key?(params, :abbrev)
      assert Map.has_key?(params, :prev_file)
      assert Map.has_key?(params, :dir)
      assert Map.has_key?(params, :next_file)
    end

    test "positional fixed notation" do
      params =
        [@position, @fixed, @direction, @range]
        |> Enum.map(&Enum.random/1)
        |> AXF.parametrize()

      assert Map.has_key?(params, :pos)
      assert Map.has_key?(params, :abbrev)
      assert params[:prev_file] == nil
      assert Map.has_key?(params, :dir)
      assert Map.has_key?(params, :next_file)
    end
  end

  test "derive_position/2" do
    wrapper = &AXF.derive_position(@default, %{pos: &1})

    assert wrapper.("+") == %Move{is_front: true}
    assert wrapper.("-") == %Move{is_front: false}
    assert AXF.derive_position(@default, %{}) == @default
  end

  test "derive_file/1 - axis - vertical" do
    assert AXF.derive_file(%Move{ch: :chariot, side: :red}, %{
             prev_file: 4,
             dir: "+",
             mvmt: 5
           }) == %Move{ch: :chariot, side: :red, prev_file: 6, next_file: 6}
  end
end
