defmodule XQNative.Engine do
  use GenServer

  require Logger

  @default_engine_path "/usr/local/bin/fairy-stockfish"

  def start_link(respond_to) do
    GenServer.start_link(__MODULE__, respond_to)
  end

  def init(respond_to) when is_pid(respond_to) do
    state = %{
      respond_to: respond_to,
      uci: false,
      ready: false,
      port: nil
    }

    {:ok, state, {:continue, :start_engine}}
  end

  def handle_continue(:start_engine, state) do
    port =
      Port.open(
        {:spawn, Application.get_env(:xq, :engine_path, @default_engine_path)},
        [:binary]
      )

    Port.command(port, "uci\n")

    Logger.debug("successfully started #{__MODULE__} engine server")

    {:noreply, %{state | port: port, uci: true}}
  end

  def handle_info({port, {:data, "id name " <> _rem}}, state) do
    Logger.debug("Engine UCI ok")

    set_option(port, "UCI_Variant", "xiangqi")
    Port.command(port, "isready\n")

    {:noreply, state}
  end

  def handle_info({_port, {:data, "readyok" <> _rem}}, state) do
    Logger.debug("Engine is ready")

    {:noreply, %{state | ready: true}}
  end

  def handle_info({_port, {:data, msg}}, state) do
    Logger.debug("Reply from engine: #{inspect(msg)}")

    {:noreply, state}
  end

  defp set_option(port, option, value) do
    Port.command(port, "setoption name #{option} value #{value}\n")
  end
end
