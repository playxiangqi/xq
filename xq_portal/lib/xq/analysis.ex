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

  def set_option(opt, value) do
    GenServer.cast(engine(), {:send, "setoption name #{opt} value #{value}\n"})
  end

  def setup do
    GenServer.cast(engine(), {:send, "position startpos"})
    set_option("multipv", "3")
    GenServer.cast(engine(), {:send, "go depth 15 searchmoves"})
  end
end
