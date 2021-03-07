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

  def send(command) do
    GenServer.cast(engine(), {:send, command})
  end

  def set_option(opt, value) do
    send("setoption name #{opt} value #{value}\n")
  end

  def setup do
    send("position startpos")
    set_option("multipv", "3")
    send("go depth 15 searchmoves")
  end

  defp engine do
    Agent.get(__MODULE__, & &1)
  end
end
