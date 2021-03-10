defmodule XQ.Parser.FEN do
  alias XQ.Core.{Board, Point}

  def parse(_notation) do
  end

  def produce(%Board{state: state, prev_point: prev_point}) do
    %{fen: fen} =
      state
      |> Enum.sort(&Point.by_abs_index/2)
      |> Enum.reduce(%{curr_rank: 0, curr_file: 0, fen: ""}, fn point, acc ->
        fen =
          acc.fen
          |> append_solidus(point, acc)
          |> append_num_spaces(point, acc)

        fen = "#{fen}#{piece(point.ch, point.side)}"

        temp_file = point.file + 1
        curr_rank = if temp_file > 9, do: point.rank + 1, else: point.rank
        curr_file = if temp_file > 9, do: 0, else: temp_file

        %{curr_rank: curr_rank, curr_file: curr_file, fen: fen}
      end)

    fen
    |> append_active_color(prev_point)
    |> append_fullmove_number()
  end

  defp append_solidus(fen, point, acc) when point.rank != acc.curr_rank, do: "#{fen}/"
  defp append_solidus(fen, _point, _acc), do: fen

  defp append_num_spaces(fen, point, acc) when point.file - acc.curr_file != 0,
    do: "#{fen}#{point.file - acc.curr_file}"

  defp append_num_spaces(fen, _point, _acc), do: fen

  defp append_active_color(fen, prev_point)
       when is_nil(prev_point) or prev_point.side == :black,
       do: "#{fen} w---"

  defp append_active_color(fen, _), do: "#{fen} b---"

  defp append_fullmove_number(fen, move_num \\ 1), do: "#{fen}#{move_num}"

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
