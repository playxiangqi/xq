defmodule XQWeb.AnaylsisChannel do
  use Phoenix.Channel
  use XQNative.Engine

  @impl true
  def join("analysis:*", _payload, socket) do
    Phoenix.PubSub.subscribe(XQ.PubSub, @internal_topic)
    XQNative.Engine.new_session(self())
    {:ok, socket}
  end

  @impl true
  def handle_info(%{event: event, payload: payload}, socket) do
    Phoenix.Channel.broadcast!(socket, event, payload)
    {:noreply, socket}
  end
end
