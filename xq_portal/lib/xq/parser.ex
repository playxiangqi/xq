defmodule XQ.Parser do
  alias __MODULE__.{AXF}

  def parse(:axf, notation), do: AXF.parse(notation)
end
