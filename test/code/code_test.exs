defmodule ElixirDetective.CodeTest do
  use ExUnit.Case
  alias ElixirDetective.Code
  alias ElixirDetective.Code.ModuleReference

  doctest ElixirDetective.Code

  describe "find_references/1" do
    test "it returns a list of references" do
      file_path = "test/fixtures/alias_example.exs"
      result = Code.find_references(file_path)

      assert Enum.count(result) == 7
      assert Enum.all?(result, fn i -> %ModuleReference{} = i end)
    end

    test "it returns the proper error when it finds a non-quotable file" do
      file_path = "test/fixtures/invalid_syntax_example.exs"

      expected_message =
        "Couldn't parse file #{file_path}: missing terminator: ' (for string starting at line 2) on line 4"

      assert_raise RuntimeError, expected_message, fn ->
        Code.find_references(file_path)
      end
    end
  end
end
