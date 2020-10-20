defmodule ElixirDetective.UI do
  def build(modules) do
    format_as_json(modules)
  end

  @template_file "./views/template.html.eex"

  defp format_as_json(modules) do
    data =
      modules
      |> Enum.map(fn m ->
        %{
          name: Enum.at(m.namespace, 0),
          full_name: Enum.join(m.namespace, "."),
          namespace: m.namespace |> List.delete_at(-1) |> Enum.join("."),
          lines_of_code: m.loc,
          dependencies: unique_list_of_dependencies(m.dependencies),
          dependents: unique_list_of_dependents(m.dependents),
          file_path: m.file_path
        }
      end)
      |> Jason.encode!()

    # When using development environment it writes the data in the UI
    # folder so we can debug with the UI in dev mode.
    if Application.get_env(:ElixirDetective, :env) == :dev do
      File.write("./ui/src/data.json", data)
    else
      result = EEx.eval_file(@template_file, data: data)
      File.write("./output.html", result)
    end
  rescue
    _ -> IO.inspect(modules)
  end

  defp unique_list_of_dependents(references) do
    references
    |> Enum.map(fn ref -> Enum.join(ref.from, ".") end)
    |> Enum.uniq()
  end

  defp unique_list_of_dependencies(references) do
    references
    |> Enum.map(fn ref -> Enum.join(ref.to, ".") end)
    |> Enum.uniq()
  end
end
