defmodule XQWeb.GraphQL.ContentTypes do
  use Absinthe.Schema.Notation

  object :opening do
    field :id, non_null(:string)
    field :name, non_null(:string)
    field :moves, list_of(:string)
  end
end
