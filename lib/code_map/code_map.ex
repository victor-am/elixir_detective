defmodule ElixirDetective.CodeMap do
  alias ElixirDetective.CodeMap.Entity
  alias ElixirDetective.Code.ModuleReference

  def generate(references) do
    references
    |> Enum.group_by(fn reference -> reference.from end)
    |> Enum.map(fn {entity_name, dependencies} ->
      base_reference = hd(dependencies)

      # Remove :defmodule references to eliminate dependencies on self
      dependencies = Enum.filter(dependencies, fn ref -> non_circular_reference?(ref) end)
      dependents = Enum.filter(references, fn ref -> ref.to == entity_name and non_circular_reference?(ref) end)

      Entity.build(%{
        type: :module,
        namespace: entity_name,
        dependencies: dependencies,
        dependents: dependents,
        file_path: base_reference.file_path,
        loc: 0
      })
    end)
  end

  defp non_circular_reference?(%ModuleReference{to: to, from: from}), do: to != from
end
