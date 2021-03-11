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

  def send_command(command) do
    GenServer.cast(engine(), {:send, command})
  end

  def set_option(opt, value) do
    send_command("setoption name #{opt} value #{value}")
  end

  def setup do
    send_command("position startpos")
    set_option("MultiPV", "3")
    search()
  end

  def submit_board(fen) do
    send_command("stop")
    send_command("position fen #{fen}")
    search()
  end

  defp search do
    send_command("go depth 15 searchmoves")
  end

  defp engine do
    Agent.get(__MODULE__, & &1)
  end
end
