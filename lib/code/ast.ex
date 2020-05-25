defmodule ElixirDetective.Code.AST do
  alias ElixirDetective.Code.ModuleReference
  alias ElixirDetective.Debug.Logger, as: Log

  def find_module_references(ast_node) do
    find(ast_node, [])
  end

  # Defmodule node
  # When found we add pass on the module name as a namespace for next
  # nodes found in this branch.
  defp find({:defmodule, _metadata, args} = ast_node, namespaces) do
    module_name = extract_module_name(ast_node)
    Log.defmodule_node(ast_node, module_name)

    new_namespaces = namespaces |> Enum.concat([module_name])
    continue(args, new_namespaces)
  end

  # Import node
  defp find({:import, _metadata, args} = ast_node, namespaces) do
    reference = build_module_reference(ast_node, namespaces)
    Log.import_node(ast_node, reference.to)

    concat_reference_and_continue(args, reference, namespaces)
  end

  # Alias node
  defp find({:__aliases__, _metadata, args} = ast_node, namespaces) do
    reference = build_module_reference(ast_node, namespaces)
    Log.alias_node(ast_node, reference.to)

    concat_reference_and_continue(args, reference, namespaces)
  end

  # Unknown node
  defp find({_token, _metadata, args} = ast_node, namespaces) do
    Log.unknown_node(ast_node)

    continue(args, namespaces)
  end

  # Block node
  defp find([do: {:__block__, _, args}] = ast_node, namespaces) when is_list(args) do
    Log.block_node(ast_node)

    continue(args, namespaces)
  end

  # This matches dead-ends in the tree
  # Ex: :SomeAtom
  defp find(ast_node, _namespaces) do
    Log.dead_end_node(ast_node)
    []
  end

  defp extract_module_name({_token, _metadata, [{_, [alias: false], module_names}]}),
    do: Enum.join(module_names, ".")
  
  defp extract_module_name({_token, _metadata1, [{:__aliases__, _metadata2, module_names}, [do: _block]]}),
    do: Enum.join(module_names, ".")
  
  defp extract_module_name({_token, _metadata, module_names}),
    do: Enum.join(module_names, ".")

  defp build_module_reference(node, namespaces) do
    module_name = extract_module_name(node)
    file_path = "to be implemented"

    {_token, [line: line_of_code], _args} = node

    ModuleReference.build(%{
      from: namespaces,
      to: module_name,
      line: line_of_code,
      file_path: file_path
    })
  end

  defp continue(args, namespaces) do
    args
    |> List.wrap()
    |> Enum.flat_map(fn node -> find(node, namespaces) end)
  end

  defp concat_reference_and_continue(args, reference, namespaces) do
    args
    |> continue(namespaces)
    |> Enum.concat([reference])
  end
end