defmodule XQWeb.AnaylsisChannel do
  use XQWeb, :channel

  require Logger

  @impl true
  def join("analysis:*", _payload, socket) do
    XQ.Analysis.new_session()
    {:ok, socket}
  end

  @impl true
  def handle_info({:status, :ready}, socket) do
    XQ.Analysis.setup()
    {:noreply, socket}
  end

  def handle_info({:engine_search, search_results}, socket) do
    Phoenix.Channel.broadcast!(socket, "analysis:moves", search_results)

    {:noreply, socket}
  end

  def handle_info(event, socket) do
    Logger.debug("AnalysisChannel received unhandled event: #{inspect(event)}")

    {:noreply, socket}
  end
end
