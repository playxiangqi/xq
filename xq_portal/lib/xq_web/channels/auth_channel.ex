defmodule XiangqiServer.AuthChannel do
  use Phoenix.Channel

  @impl true
  def join("user:guest", _message, socket) do
    {:ok, %{guest_id: generate_guest_id()}, socket}
  end

  @impl true
  def join("user:" <> _id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  defp generate_guest_id do
    {min, max} = {String.to_integer("100000", 36), String.to_integer("ZZZZZZ", 36)}

    id = max |> Kernel.-(min) |> :rand.uniform() |> Kernel.+(min) |> Integer.to_string(36)
    "Guest_" <> id
  end
end