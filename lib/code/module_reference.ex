defmodule ElixirDetective.Code.ModuleReference do
  @derive {Jason.Encoder, only: [:reference_type, :file_path, :line, :from, :to]}

  # TODO: Add doc for each field
  defstruct [
    :reference_type,
    :file_path,
    :line,
    :from,
    :to
  ]

  def build(attrs) do
    %__MODULE__{}
    |> Map.merge(attrs)
  end
end
