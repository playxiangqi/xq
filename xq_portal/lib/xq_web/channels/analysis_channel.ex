defmodule XQWeb.AnaylsisChannel do
  use XQWeb, :channel

  require Logger

  @impl true
  def join("analysis:guest_" <> guest_id, _payload, socket) do
    XQ.Analysis.new_session()
    {:ok, assign(socket, :guest_id, guest_id)}
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
end
