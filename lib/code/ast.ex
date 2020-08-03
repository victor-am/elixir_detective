defmodule ElixirDetective.Code.AST do
  alias ElixirDetective.Code.ModuleReference
  alias ElixirDetective.Debug.Logger, as: Log

  def find_module_references(ast_node) do
    find(ast_node, [])
  end

  # Defmodule node
  # When found we add pass on the module name as a namespace for next
  # nodes found in this branch of the AST. We also register this as a
  # reference (to the module being declared).
  defp find({:defmodule, _metadata, args} = ast_node, namespaces) do
    reference = build_module_reference(:defmodule, ast_node, namespaces)
    Log.defmodule_node(ast_node, reference.to)

    new_namespaces = Enum.concat(namespaces, reference.to)
    concat_reference_and_continue(args, [reference], new_namespaces)
  end

  # Import node
  defp find({:import, _metadata, args} = ast_node, namespaces) do
    reference = build_module_reference(:import, ast_node, namespaces)
    Log.import_node(ast_node, reference.to)

    concat_reference_and_continue(args, [reference], namespaces)
  end

  # Alias with multiple modules node
  # Example:
  # alias Foo.{Bar, Batz}
  defp find(
         {:alias, _meta,
          [
            {
              {:., _meta2, [{:__aliases__, _meta3, alias_namespaces}, :{}]},
              _meta4,
              args
            }
          ]} = _ast_node,
         namespaces
       )
       when is_list(args) do
    references =
      Enum.map(args, fn arg_node ->
        reference = build_module_reference(:alias, arg_node, namespaces, alias_namespaces)
        Log.alias_node(arg_node, reference.to)
        reference
      end)

    concat_reference_and_continue(args, references, namespaces)
  end

  # Alias node
  defp find({:alias, _metadata, args} = ast_node, namespaces) do
    reference = build_module_reference(:alias, ast_node, namespaces)
    Log.alias_node(ast_node, reference.to)

    concat_reference_and_continue(args, [reference], namespaces)
  end

  # Do node
  defp find([do: {_token, _, _args} = arg] = ast_node, namespaces) do
    Log.do_node(ast_node)

    continue([arg], namespaces)
  end

  # Unknown node
  defp find({_token, _metadata, args} = ast_node, namespaces) do
    Log.unknown_node(ast_node)

    continue(args, namespaces)
  end

  # This matches dead-ends in the tree
  # Ex: :SomeAtom
  defp find(ast_node, _namespaces) do
    Log.dead_end_node(ast_node)
    []
  end

  defp extract_module_name({_token, _meta1, [{:__aliases__, _meta2, module_names}, [do: _block]]}),
    do: module_names

  defp extract_module_name({_token, _meta1, [{:__aliases__, _meta2, module_names}]}),
    do: module_names

  # The as: _alias here referes to manual alias naming like:
  # alias Foo, as: Bar
  defp extract_module_name({_token, _meta1, [{:__aliases__, _meta2, module_names}, [as: _alias]]}),
    do: module_names

  defp extract_module_name({:__aliases__, _meta1, module_names}),
    do: module_names

  defp build_module_reference(reference_type, node, current_module, reference_extra_namespace \\ []) do
    # Extra namespace is used for aliases pointing to multiple modules
    module_full_name =
      reference_extra_namespace
      |> Enum.concat(extract_module_name(node))

    file_path = "to be implemented"

    {_token, [line: line_of_code], _args} = node

    ModuleReference.build(%{
      reference_type: reference_type,
      from: current_module,
      to: module_full_name,
      line: line_of_code,
      file_path: file_path
    })
  end

  defp continue(args, namespaces) do
    args
    |> List.wrap()
    |> Enum.flat_map(fn node -> find(node, namespaces) end)
  end

  defp concat_reference_and_continue(args, references, namespaces) do
    args
    |> continue(namespaces)
    |> Enum.concat(references)
  end
end
