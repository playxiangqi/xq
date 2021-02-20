defmodule XQWeb.GraphQL.Resolvers.Content do
  require Logger

  def list_openings(_root, _args, _info) do
    {:ok, %{body: content, status: 200}} =
      Finch.build(:get, XQWeb.Service.archive() <> "/openings")
      |> Finch.request(XQ.Finch)

    Jason.decode(content, keys: :atoms!)
  end
end
