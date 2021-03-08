defmodule XQ.AnalysisTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, agent_pid} = XQ.Analysis.new_session()

    XQ.Analysis.send_command("uci")

    %{agent: agent_pid}
  end

  test "set_option/2" do
    assert :ok = XQ.Analysis.set_option("UCI_Variant", "xiangqi")
  end

  test "setup/0" do
    assert :ok = XQ.Analysis.setup()
  end
end
