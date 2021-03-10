defmodule XQ.Parser do
  alias __MODULE__.{AXF, FEN}

  def parse(:axf, notation), do: AXF.parse(notation)

  def produce(:fen, board), do: FEN.produce(board)
end
