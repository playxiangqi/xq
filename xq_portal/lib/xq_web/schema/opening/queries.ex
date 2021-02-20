defmodule XQWeb.Schema.Opening.Queries do
  use Absinthe.Schema.Notation

  alias XQWeb.Schema.Opening.Resolvers

  object :opening_queries do
    @desc "Get all openings"
    field :openings, list_of(:opening) do
      resolve &Resolvers.list_openings/3
    end
  end
end
