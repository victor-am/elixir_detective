defmodule ElixirDetective.Code.ModuleReference do
  # @derive {Jason.Encoder, only: [:file_path, :line, :from, :to]}

  # TODO: Add doc for each field
  defstruct [
    :file_path,
    :line,
    :from,
    :to
  ]

  def build(attrs) do
    attributes =
      attrs
      |> cast_to_string(:to)
      |> cast_to_string(:from)

    Map.merge(%__MODULE__{}, attributes)
  end

  defp cast_to_string(attrs, key) do
    string_value = attrs |> Map.get(key) |> to_string()
    %{attrs | key => string_value}
  end
end
