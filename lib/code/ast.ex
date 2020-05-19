defmodule ElixirDetective.Code.AST do
  alias ElixirDetective.Code.ModuleReference
  alias ElixirDetective.Debug.Logger, as: Log

  def find_module_references(ast_node) do
    find(ast_node)
  end

  # Defmodule node
  defp find({:defmodule, _metadata, args} = ast_node) do
    module_name = extract_module_name(ast_node)
    Log.defmodule_node(ast_node, module_name)

    continue(args)
  end

  # Import node
  defp find({:import, _metadata, args} = ast_node) do
    reference = build_module_reference(ast_node)
    Log.import_node(ast_node, reference.to)

    concat_reference_and_continue(args, reference)
  end

  # Alias node
  defp find({:__aliases__, _metadata, args} = ast_node) do
    reference = build_module_reference(ast_node)
    Log.alias_node(ast_node, reference.to)

    concat_reference_and_continue(args, reference)
  end

  # Unknown node
  defp find({_token, _metadata, args} = ast_node) do
    Log.unknown_node(ast_node)

    continue(args)
  end

  # Block node
  defp find(do: {:__block__, _, args} = ast_node) when is_list(args) do
    Log.block_node(ast_node)

    continue(args)
  end

  # This matches dead-ends in the tree
  # Ex: :SomeAtom
  defp find(ast_node) do
    Log.dead_end_node(ast_node)
    []
  end

  defp extract_module_name({_token, _metadata, [{_, [alias: false], module_names}]}),
    do: Enum.join(module_names, ".")
  
  defp extract_module_name({_token, _metadata, [{:__aliases__, _metadata, module_names}, [do: _block]]}),
    do: Enum.join(module_names, ".")
  
  defp extract_module_name({_token, _metadata, module_names}),
    do: Enum.join(module_names, ".")

  defp build_module_reference(node) do
    module_name = extract_module_name(node)
    current_module_name = "to be implemented"
    file_path = "to be implemented"

    {_token, [line: line_of_code], _args} = node

    ModuleReference.build(%{
      from: current_module_name,
      to: module_name,
      line: line_of_code,
      file_path: file_path
    })
  end

  defp continue(args) do
    args
    |> List.wrap()
    |> Enum.flat_map(fn node -> find(node) end)
  end

  defp concat_reference_and_continue(args, reference) do
    args
    |> continue
    |> Enum.concat([reference])
  end
end