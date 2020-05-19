defmodule ElixirDetective do
  def main(args \\ []) do
    ExCLI.run!(ElixirDetective.CLI, args)
  end
end
