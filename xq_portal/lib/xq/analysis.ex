defmodule XQ.Analysis do
  use Agent

  defmacro __using__(_) do
    quote do
      @internal_topic "_analysis:*"
    end
  end

  def start_link(pid) do
    {:ok, engine} =
      DynamicSupervisor.start_child(
        XQNative.Supervisor,
        {XQNative.Engine, pid}
      )

    GenServer.cast(engine, {:send, "position startpos"})
    GenServer.cast(engine, {:send, "go depth 15 searchmoves"})

    Agent.start_link(fn -> %{engine: engine} end, name: __MODULE__)
  end
end
