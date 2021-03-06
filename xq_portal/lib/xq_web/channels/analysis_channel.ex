defmodule XQWeb.AnaylsisChannel do
  use Phoenix.Channel

  require Logger

  @impl true
  def join("analysis:*", _payload, socket) do
    XQ.Analysis.new_session()
    {:ok, socket}
  end

  @impl true
  def handle_info(%{moves: moves}, socket) do
    Phoenix.Channel.broadcast!(socket, "analysis:moves", %{moves: moves})
    {:noreply, socket}
  end

  def handle_info(event, socket) do
    Logger.debug("AnalysisChannel received unhandled event: #{inspect(event)}")

    {:noreply, socket}
  end
end
