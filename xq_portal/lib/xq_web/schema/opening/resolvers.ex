defmodule XQWeb.Schema.Opening.Resolvers do
  require Logger

  def list_openings(_root, _args, _info) do
    {:ok, %{body: content, status: 200}} =
      Finch.request(
        Finch.build(:get, "#{XQWeb.Service.archive()}/openings"),
        XQ.Finch
      )

    Jason.decode(content, keys: :atoms!)
  end
end
