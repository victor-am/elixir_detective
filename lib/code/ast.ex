defmodule ElixirDetective.Code.AST do
  alias ElixirDetective.Code.ModuleReference
  alias ElixirDetective.Debug.Logger, as: Log

  def find_module_references(ast_node, file_path) do
    find(ast_node, [], file_path)
  end

  # Defmodule node
  # When found we add pass on the module name as a namespace for next
  # nodes found in this branch of the AST.
  defp find({:defmodule, _metadata, args} = ast_node, namespaces, file_path) do
    reference = build_module_reference(ast_node, namespaces, file_path)
    Log.defmodule_node(ast_node, reference.to)

    new_namespaces = Enum.concat(namespaces, reference.to)
    continue(args, new_namespaces, file_path)
  end

  # Alias node
  defp find({:__aliases__, _metadata, args} = ast_node, namespaces, file_path) do
    reference = build_module_reference(ast_node, namespaces, file_path)
    Log.alias_node(ast_node, reference.to)

    concat_reference_and_continue(args, [reference], namespaces, file_path)
  end

  # Alias with multiple modules node
  # Example:
  # alias Foo.{Bar, Batz}
  defp find(
         {_token, _meta,
          [
            {
              {:., _meta2, [{:__aliases__, _meta3, alias_namespaces}, :{}]},
              _meta4,
              args
            }
          ]} = _ast_node,
         namespaces,
         file_path
       )
       when is_list(args) do
    references =
      Enum.map(args, fn arg_node ->
        reference = build_module_reference(arg_node, namespaces, file_path, alias_namespaces)
        Log.alias_node(arg_node, reference.to)
        reference
      end)

    concat_reference_and_continue([], references, namespaces, file_path)
  end

  # Alias with multiple modules node
  # Example:
  # alias __MODULE__.{Bar, Batz}
  defp find(
         {_token, _meta,
          [
            {
              {:., _meta2, [{:__MODULE__, _meta3, nil}, :{}]},
              _meta4,
              args
            }
          ]} = _ast_node,
         namespaces,
         file_path
       )
       when is_list(args) do
    references =
      Enum.map(args, fn arg_node ->
        reference = build_module_reference(arg_node, namespaces, file_path, namespaces)
        Log.alias_node(arg_node, reference.to)
        reference
      end)

    concat_reference_and_continue([], references, namespaces, file_path)
  end

  # Do node
  defp find([do: {_token, _, _args} = arg] = ast_node, namespaces, file_path) do
    Log.do_node(ast_node)

    continue([arg], namespaces, file_path)
  end

  # Unknown node
  defp find({_token, _metadata, args} = ast_node, namespaces, file_path) do
    Log.unknown_node(ast_node)

    continue(args, namespaces, file_path)
  end

  # This matches dead-ends in the tree
  # Ex: :SomeAtom
  defp find(ast_node, _namespaces, _file_path) do
    Log.dead_end_node(ast_node)
    []
  end

  defp extract_module_name({_token, _meta1, [{:__aliases__, _meta2, module_names}, _params]}) do
    module_names
  end

  defp extract_module_name({_token, _meta1, [{:__aliases__, _meta2, module_names}]}) do
    module_names
  end

  defp extract_module_name({:__aliases__, _meta1, module_names}) do
    module_names
  end

  defp extract_module_name({:defmodule, _meta1, [module_names | _args]}) when is_atom(module_names) do
    module_names
    |> to_string()
    |> String.split(".")
    |> Enum.map(fn m -> String.to_atom(m) end)
  end

  defp extract_module_name({_token, _meta1, [{:__MODULE__, meta2, nil}]}) do
    [{:__MODULE__, meta2, nil}]
  end

  defp build_module_reference(node, current_module, file_path, reference_extra_namespace \\ []) do
    module_name =
      node
      |> extract_module_name()
      |> replace__MODULE__mentions(current_module)

    # Extra namespace is used for aliases pointing to multiple modules
    module_full_name =
      reference_extra_namespace
      |> replace__MODULE__mentions(current_module)
      |> Enum.concat(module_name)

    {_token, [line: line_of_code], _args} = node

    ModuleReference.build(%{
      from: current_module,
      to: module_full_name,
      line: line_of_code,
      file_path: file_path
    })
  end

  # This is used to replace mentions of the __MODULE__ variable in the AST with the name
  # of the current module, allowing us to have the real namespace of the referenced module
  defp replace__MODULE__mentions(module_names, current_module) do
    Enum.map(module_names, fn module_name ->
      case module_name do
        :__MODULE__ -> current_module
        {:__MODULE__, _meta, _} -> current_module
        _ -> module_name
      end
    end)
    |> List.flatten()
  end

  defp continue(args, namespaces, file_path) do
    args
    |> List.wrap()
    |> Enum.flat_map(fn node -> find(node, namespaces, file_path) end)
  end

  defp concat_reference_and_continue(args, references, namespaces, file_path) do
    args
    |> continue(namespaces, file_path)
    |> Enum.concat(references)
  end
end
