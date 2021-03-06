defmodule XQ.Analysis do
  use Agent

  def new_session do
    {:ok, engine} =
      DynamicSupervisor.start_child(
        XQ.SessionSupervisor,
        {XQNative.Engine, self()}
      )

    Agent.start_link(fn -> engine end, name: __MODULE__)
  end

  def engine do
    Agent.get(__MODULE__, & &1)
  end

  def setup do
    GenServer.cast(engine(), {:send, "position startpos"})
    GenServer.cast(engine(), {:send, "setoption name multipv value 3"})
    GenServer.cast(engine(), {:send, "go depth 15 searchmoves"})
  end
end
