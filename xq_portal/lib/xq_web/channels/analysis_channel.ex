defmodule XQWeb.AnaylsisChannel do
  use XQWeb, :channel

  @impl true
  def join("analysis:guest_" <> guest_id, _payload, socket) do
    XQ.Analysis.new_session()
    {:ok, assign(socket, :guest_id, guest_id)}
  end

  @impl true
  def handle_in("analysis:board_state", payload, socket) do
    :fen
    |> XQ.Parser.produce(unmarshal_board(payload))
    |> XQ.Analysis.submit_board()

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

  defp unmarshal_board(%{"points" => points} = board) do
    %XQ.Core.Board{
      points: Enum.map(points, &unmarshal_point/1),
      prev_point: unmarshal_point(Map.get(board, "prevPoint"))
    }
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
