defmodule XQWeb.AnaylsisChannel do
  use XQWeb, :channel

  require Logger

  @impl true
  def join("analysis:guest_" <> guest_id, _payload, socket) do
    XQ.Analysis.new_session()
    {:ok, assign(socket, :guest_id, guest_id)}
  end

  @impl true
  def handle_in(
        "analysis:board_state",
        %{"state" => state, "prev_point" => prev_point},
        socket
      ) do
    fen =
      XQ.Parser.produce(
        :fen,
        %XQ.Core.Board{
          state: Enum.map(state, &unmarshal_point/1),
          prev_point: unmarshal_point(prev_point)
        }
      )

    Logger.info("fen: #{fen}")
    XQ.Analysis.submit_board(fen)

    {:noreply, socket}
  end

  @impl true
  def handle_info({:status, :ready}, socket) do
    XQ.Analysis.setup()
    {:noreply, socket}
  end

  def handle_info({:engine_search, search_results}, socket) do
    Phoenix.Channel.broadcast!(
      socket,
      "analysis:guest_#{socket.assigns.guest_id}",
      search_results
    )

    {:noreply, socket}
  end

  def handle_info(event, socket) do
    Logger.debug("AnalysisChannel received unhandled event: #{inspect(event)}")

    {:noreply, socket}
  end

  defp unmarshal_point(nil), do: nil

  defp unmarshal_point(%{} = point) do
    point
    |> Map.take(["ch", "side", "rank", "file"])
    |> Map.new(fn {k, v} ->
      {String.to_atom(k),
       case v do
         s when is_binary(s) ->
           String.to_atom(s)

         v ->
           v
       end}
    end)
  end
end
