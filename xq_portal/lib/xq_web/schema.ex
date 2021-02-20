defmodule XQWeb.Schema do
  use Absinthe.Schema

  import_types __MODULE__.Opening.{Queries, Types}

  query do
    import_fields :opening_queries
  end
end
