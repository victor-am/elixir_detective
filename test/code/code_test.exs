defmodule ElixirDetective.CodeTest do
  use ExUnit.Case
  alias ElixirDetective.Code
  alias ElixirDetective.Code.ModuleReference

  doctest ElixirDetective.Code

  describe "find_references/1" do
    test "it returns a list of references for aliases" do
      file_path = "test/fixtures/code_example.exs"
      result = Code.find_references(file_path)

      assert result == [
               %ElixirDetective.Code.ModuleReference{
                 file_path: "/Users/victor/Projects/elixir_detective/test/fixtures/code_example.exs",
                 from: "MyModule",
                 line: 7,
                 to: "MyNamespace.YetAnotherModule"
               },
               %ElixirDetective.Code.ModuleReference{
                 file_path: "/Users/victor/Projects/elixir_detective/test/fixtures/code_example.exs",
                 from: "MyModule",
                 line: 8,
                 to: "OtherModule"
               },
               %ElixirDetective.Code.ModuleReference{
                 file_path: "/Users/victor/Projects/elixir_detective/test/fixtures/code_example.exs",
                 from: "MyModule",
                 line: 9,
                 to: "Enum"
               },
               %ElixirDetective.Code.ModuleReference{
                 file_path: "/Users/victor/Projects/elixir_detective/test/fixtures/code_example.exs",
                 from: "MyModule",
                 line: 13,
                 to: "MyModule.Module3"
               }
             ]
    end
  end
end
