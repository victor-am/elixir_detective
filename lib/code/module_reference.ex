defmodule ElixirDetective.Code.ModuleReference do
  defstruct [
    :file_path,
    :line,
    :from,
    :to,
  ]

  def build(attrs) do
    %__MODULE__{}
    |> Map.merge(attrs)
  end
end