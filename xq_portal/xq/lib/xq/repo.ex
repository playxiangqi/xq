defmodule XQ.Repo do
  use Ecto.Repo,
    otp_app: :xq,
    adapter: Ecto.Adapters.Postgres
end
