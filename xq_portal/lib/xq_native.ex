defmodule XQNative do
  require Logger

  @on_load :load_nifs
  @nif_file "./cmake/build/lib/xq_native"

  def load_nifs do
    case @nif_file |> String.to_charlist() |> :erlang.load_nif(0) do
      :ok ->
        Logger.info("Loaded NIF #{__MODULE__}")

      {:error, {:reload, _}} ->
        :ok

      {:error, reason} ->
        Logger.error("Failed to load NIF #{__MODULE__}: #{inspect(reason)}")
    end
  end
end
