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

  test "submit_board/2" do
    assert :ok = XQ.Analysis.submit_board("4kaR2/4a4/3hR4/7H1/9/9/9/9/4Ap1r1/3AK3c w---1")
  end
end
