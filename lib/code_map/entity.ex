defmodule ElixirDetective.CodeMap.Entity do
  # TODO: Add doc for each field
  defstruct [
    :type,
    :namespace,
    :file_path,
    :loc,
    :dependencies
  ]

  def build(attrs) do
    %__MODULE__{}
    |> Map.merge(attrs)
  end
end
