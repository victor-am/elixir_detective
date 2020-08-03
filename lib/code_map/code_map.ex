defmodule ElixirDetective.CodeMap do
  alias ElixirDetective.CodeMap.Entity

  def generate(references) do
    references
    |> Enum.group_by(fn reference -> reference.to end)
    |> Enum.map(fn {entity_name, dependents} ->
      ref = hd(dependents)
      dependencies = Enum.filter(references, fn ref -> ref.from == entity_name end)

      Entity.build(%{
        type: :module,
        namespace: entity_name,
        dependencies: dependencies,
        dependents: dependents,
        file_path: ref.file_path,
        loc: 0
      })
    end)
  end
end
