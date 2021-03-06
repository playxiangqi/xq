defmodule XQ.Analysis do
  use Agent

  def new_session() do
    {:ok, engine} =
      DynamicSupervisor.start_child(
        XQ.SessionSupervisor,
        {XQNative.Engine, self()}
      )

    GenServer.cast(engine, {:send, "position startpos"})
    GenServer.cast(engine, {:send, "go depth 15 searchmoves"})

    Agent.start_link(fn -> engine end, name: __MODULE__)
  end
end
