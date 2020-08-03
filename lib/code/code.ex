defmodule ElixirDetective.Code do
  alias ElixirDetective.Code.{AST, Files}

  def find_references(path) do
    path
    |> Files.find_files_on_folder()
    |> find_references_from_files()
  end

  defp find_references_from_files(files) do
    Enum.flat_map(files, fn file_path -> analyze_file(file_path) end)
  end

  defp analyze_file(file_path) do
    {:ok, code} = File.read(file_path)
    {:ok, ast} = Code.string_to_quoted(code)

    AST.find_module_references(ast)
  end
end
