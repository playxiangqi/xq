defmodule Mix.Tasks.Compile.Cmake do
  use Mix.Task

  @impl true
  def run(_args) do
    {result, _errcode} = System.cmd("make", ["-s", "build"])
    IO.puts(result)
  end
end
