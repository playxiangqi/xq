defmodule XQWeb.MatchChannel do
  use Phoenix.Channel

  @impl true
  def join("match:lobby", _message, socket) do
    {:ok, socket}
  end

  def join("match:" <> _id, _params, _socket) do
    {:error, %{reason: "invalid match ID"}}
  end
end
