defmodule ElixirDetective.Code.ASTTest do
  use ExUnit.Case
  alias ElixirDetective.Code.{AST, ModuleReference}

  doctest ElixirDetective.Code.AST

  describe "when looking for aliases" do
    test "it finds simple aliases" do
      {:ok, ast} = load_fixture_code("alias_example")

      expected_module_reference = %ModuleReference{
        reference_type: :alias,
        file_path: "to be implemented",
        line: 2,
        from: [:SimpleModule],
        to: [:OtherModule]
      }

      result = AST.find_module_references(ast)

      assert Enum.member?(result, expected_module_reference)
    end

    test "it finds aliases with 'as' parameter" do
      {:ok, ast} = load_fixture_code("alias_example")

      expected_module_reference = %ModuleReference{
        reference_type: :alias,
        file_path: "to be implemented",
        line: 3,
        from: [:SimpleModule],
        to: [:MyNamespace, :YetAnotherModule]
      }

      result = AST.find_module_references(ast)

      assert Enum.member?(result, expected_module_reference)
    end

    test "it finds aliases pointing to multiple modules" do
      {:ok, ast} = load_fixture_code("alias_example")

      expected_module_reference1 = %ModuleReference{
        reference_type: :alias,
        file_path: "to be implemented",
        line: 4,
        from: [:SimpleModule],
        to: [:MyNamespace, :Module1]
      }

      expected_module_reference2 = %ModuleReference{
        reference_type: :alias,
        file_path: "to be implemented",
        line: 4,
        from: [:SimpleModule],
        to: [:MyNamespace, :Module2]
      }

      result = AST.find_module_references(ast)

      assert Enum.member?(result, expected_module_reference1)
      assert Enum.member?(result, expected_module_reference2)
    end
  end

  describe "when looking for imports" do
    test "it finds simple imports" do
      {:ok, ast} = load_fixture_code("import_example")

      expected_module_reference = %ModuleReference{
        reference_type: :import,
        file_path: "to be implemented",
        line: 2,
        from: [:SimpleModule],
        to: [:OtherModule]
      }

      result = AST.find_module_references(ast)

      assert Enum.member?(result, expected_module_reference)
    end
  end

  defp load_fixture_code(fixture_name) do
    file_path = "test/fixtures/#{fixture_name}.exs"
    {:ok, code} = File.read(file_path)
    Code.string_to_quoted(code)
  end
end
