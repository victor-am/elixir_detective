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
    {:ok, code_as_text} = File.read(file_path)

    case Code.string_to_quoted(code_as_text) do
      {:ok, ast} -> AST.find_module_references(ast)
      # Line:    the line where it failed to parse, ex: "1"
      # Message: the error message, ex: "syntax error before:"
      # Token:   the symbol used as reference, ex: "'<'"
      {:error, {line, message, token}} -> raise "Couldn't parse file #{file_path}: #{message}#{token} on line #{line}"
    end
  end
end
