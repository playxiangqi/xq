defmodule XQ.Parser.FEN do
  alias XQ.Core.{Board, Point}

  def parse(_notation) do
  end

  def produce(%Board{state: state, prev_point: prev_point}) do
    %{fen: fen} =
      state
      |> Enum.sort(&(Point.by_rank(&1, &2) and Point.by_rank(&1, &2)))
      |> Enum.reduce(%{curr_rank: 0, curr_file: 0, fen: ""}, fn point, acc ->
        fen = if acc.curr_rank != point.rank, do: "#{acc.fen}/"
        fen = "#{fen}#{point.file - acc.curr_file}#{piece(point.ch, point.side)}"

        %{curr_rank: point.rank, curr_file: point.file, fen: fen}
      end)

    fen =
      if prev_point == nil or prev_point.side == :black,
        do: "#{fen} w---1",
        else: "#{fen} b---1"

    fen
  end

  def piece(:advisor, :red), do: "A"
  def piece(:advisor, :black), do: "a"
  def piece(:soldier, :red), do: "P"
  def piece(:soldier, :black), do: "p"
  def piece(:cannon, :red), do: "C"
  def piece(:cannon, :black), do: "c"
  def piece(:horse, :red), do: "H"
  def piece(:horse, :black), do: "h"
  def piece(:chariot, :red), do: "R"
  def piece(:chariot, :black), do: "r"
  def piece(:elephant, :red), do: "E"
  def piece(:elephant, :black), do: "e"
  def piece(:general, :red), do: "K"
  def piece(:general, :black), do: "k"
end
