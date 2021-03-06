defmodule XQNative.Engine do
  defmacro __using__(_) do
    quote do
      @internal_topic "_engine:*"
    end
  end

  def new_session(pid) when is_pid(pid) do
    DynamicSupervisor.start_child(
      XQNative.Supervisor,
      {XQNative.Engine.Server, pid}
    )

    GenServer.cast(pid, {:board, "startpos"})
  end
end
