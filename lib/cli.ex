defmodule ElixirDetective.CLI do
  use ExCLI.DSL

  name("elixir_detective")
  description("Elixir Detective ~ Investigating your code dependencies")

  long_description(~s"""
  This is my long description
  """)

  option(:verbose, count: true, aliases: [:v])

  command :investigate do
    aliases([:i])
    description("Analyzes the all elixir files from a given directory")

    long_description("""
    Analyzes all elixir files from a given directory and outputs the findings.
    """)

    argument(:directory)
    option(:verboose, help: "outputs the whole AST navigation process")

    run context do
      IO.puts("Starting analysis...")
      result = ElixirDetective.Code.analyze(context.directory)
      IO.puts("Dependencies found: #{inspect(result, pretty: true)}")
    end
  end
end
