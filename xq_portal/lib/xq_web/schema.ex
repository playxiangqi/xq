defmodule XQWeb.Schema do
  use Absinthe.Schema
  import_types XQWeb.GraphQL.ContentTypes

  alias XQWeb.GraphQL.Resolvers

  query do
    @desc "Get all openings"
    field :openings, list_of(:opening) do
      resolve &Resolvers.Content.list_openings/3
    end
  end
end
