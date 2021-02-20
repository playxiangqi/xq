defmodule XQWeb.Service do
  def archive, do: Application.get_env(:xq, :archive_service)
end
