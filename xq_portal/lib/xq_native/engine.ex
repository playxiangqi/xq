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

  def handle_info({_port, {:data, "readyok" <> _rem}}, %{respond_to: pid} = state) do
    Logger.debug("Engine is ready")

    send(pid, {:status, :ready})
    {:noreply, %{state | ready: true}}
  end

  def handle_info({_port, {:data, "info " <> info}}, %{respond_to: pid} = state) do
    Logger.debug("Reply from engine: #{inspect(info)}")

    {best_move, results} =
      info
      |> String.trim()
      |> String.split(~r/\R/)
      |> Enum.map(&String.replace_leading(&1, "info ", ""))
      |> Enum.split_with(&String.starts_with?(&1, "bestmove"))

    results =
      results
      |> Enum.map(&String.split(&1, " pv "))
      |> Enum.map(fn [metadata | lines] ->
        %{
          metadata:
            metadata
            |> String.replace("score cp", "scorecp")
            |> String.split(" ")
            |> Enum.chunk_every(2)
            |> Enum.map(&List.to_tuple(&1))
            |> Enum.into(%{}, fn {k, v} -> {k, String.to_integer(v)} end),
          lines:
            lines
            |> List.first()
            |> String.split(" ")
            |> Enum.chunk_every(2)
        }
      end)

    send(pid, {:engine_search, %{best_move: best_move, results: results}})
    {:noreply, state}
  end

  def handle_info({_port, {:data, msg}}, state) do
    Logger.debug("Reply from engine: #{inspect(msg)}")
    {:noreply, state}
  end

  def handle_cast({:send, command}, %{port: port} = state) do
    Port.command(port, command <> "\n")

    Map.put(state, :status, :thinking)

    {:noreply, state}
  end

  defp set_option(port, option, value) do
    Port.command(port, "setoption name #{option} value #{value}\n")
  end
end
