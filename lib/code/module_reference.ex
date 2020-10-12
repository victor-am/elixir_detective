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
    valid_attributes =
      attrs
      |> validate_to()

    Map.merge(%__MODULE__{}, valid_attributes)
  end

  defp validate_to(%{to: to} = params) do
    if is_list(to) do
      params
    else
      raise_wrong_type_error("to", "list", to)
    end
  end

  defp validate_to(_) do
    raise_missing_field_error("to")
  end

  # TODO: create custom errors
  defp raise_missing_field_error(field_name) do
    raise "[Internal Error] Field missing for ModuleReference struct: #{field_name}"
  end

  defp raise_wrong_type_error(field_name, expected_type, received_value) do
    raise "[Internal Error] Field with wrong type for ModuleReference struct: #{field_name} was expected to be #{
            expected_type
          } but was received as: #{inspect(received_value)}"
  end
end
