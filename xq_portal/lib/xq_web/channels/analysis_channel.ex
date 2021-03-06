defmodule XQWeb.AnaylsisChannel do
  use Phoenix.Channel
  use XQ.Analysis

  @impl true
  def join("analysis:*", _payload, socket) do
    Phoenix.PubSub.subscribe(XQ.PubSub, @internal_topic)
    XQ.Analysis.start_link(self())
    {:ok, socket}
  end

  @impl true
  def handle_info(%{event: event, payload: payload}, socket) do
    Phoenix.Channel.broadcast!(socket, event, payload)
    {:noreply, socket}
  end
end
