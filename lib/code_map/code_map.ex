defmodule ElixirDetective.CodeMap do
  alias ElixirDetective.CodeMap.Entity
  alias ElixirDetective.Code.ModuleReference

  def generate(references) do
    references
    |> Enum.group_by(fn reference -> reference.from end)
    |> Enum.map(fn {entity_name, dependencies} ->
      file_path = hd(dependencies).file_path

      dependencies =
        dependencies
        |> only_non_blank()
        |> only_non_circular()

      dependents =
        references
        |> only_to_module(entity_name)
        |> only_non_blank()
        |> only_non_circular()

      Entity.build(%{
        type: :module,
        namespace: entity_name,
        dependencies: dependencies,
        dependents: dependents,
        file_path: file_path,
        loc: 0
      })
    end)
  end

  defp only_to_module(references, module) do
    Enum.filter(references, fn ref ->
      ref.to == module
    end)
  end

  defp only_non_circular(references) do
    Enum.filter(references, fn ref ->
      ref.to != ref.from
    end)
  end

  defp only_non_blank(references) do
    Enum.filter(references, fn ref ->
      case ref do
        %ModuleReference{to: [], from: _} -> false
        %ModuleReference{to: _, from: []} -> false
        _ -> true
      end
    end)
  end
end
