defmodule ElixirDetective.Code.AST do
  alias ElixirDetective.Code.ModuleReference
  alias ElixirDetective.Debug.Logger, as: Log

  # Options passed down the tree.
  # This provides a way to the information uncovered at one
  # node influence on another node further down the tree.
  #
  # file_path         - pending description
  # open_alias_block? - pending description
  # aliases           - Lists all aliases in effect on this branch, ex: %{alias_name => aliased_module}
  @default_options %{
    file_path: "",
    open_alias_block?: false,
    aliases: %{}
  }

  def find_module_references(ast_node, file_path) do
    find(ast_node, [], %{@default_options | file_path: file_path})
  end

  # Defmodule node
  # When found we add pass on the module name as a namespace for next
  # nodes found in this branch of the AST.
  defp find({:defmodule, _metadata, args} = ast_node, namespaces, options) do
    reference = build_module_reference(ast_node, namespaces, options)
    Log.defmodule_node(ast_node, reference.to)

    new_namespaces = Enum.concat(namespaces, reference.to)
    continue(args, new_namespaces, options)
  end

  # Alias node
  defp find({:alias, _metadata, args} = ast_node, namespaces, options) do
    Log.alias_node(ast_node)

    continue(args, namespaces, %{options | open_alias_block?: true})
  end

  # Reference node
  defp find({:__aliases__, _metadata, args} = ast_node, namespaces, options) do
    reference = build_module_reference(ast_node, namespaces, options)
    Log.reference_node(ast_node, reference.to)

    new_options = %{
      options |
      open_alias_block?: false,
      aliases: add_aliases_if_block_is_open(options, reference)
    }
    concat_reference_and_continue(args, [reference], namespaces, new_options)
  end

  # Reference using another module as namespace with multiple modules
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
         options
       )
       when is_list(args) do
    references =
      Enum.map(args, fn arg_node ->
        reference = build_module_reference(arg_node, namespaces, options, alias_namespaces)
        Log.reference_node(arg_node, reference.to)
        reference
      end)

    new_options = %{
      options |
      open_alias_block?: false,
      aliases: add_aliases_if_block_is_open(options, references)
    }
    concat_reference_and_continue([], references, namespaces, new_options)
  end

  # Reference using __MODULE__ as namespace with multiple modules
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
         options
       )
       when is_list(args) do
    references =
      Enum.map(args, fn arg_node ->
        reference = build_module_reference(arg_node, namespaces, options, namespaces)
        Log.reference_node(arg_node, reference.to)
        reference
      end)

    new_options = %{
      options |
      open_alias_block?: false,
      aliases: add_aliases_if_block_is_open(options, references)
    }
    concat_reference_and_continue([], references, namespaces, new_options)
  end

  # Do node
  defp find([do: {_token, _, _args} = arg] = ast_node, namespaces, options) do
    Log.do_node(ast_node)

    continue([arg], namespaces, options)
  end

  # Block node
  defp find({:__block__, _meta, args} = ast_node, namespaces, options) do
    Log.block_node(ast_node)

    continue(args, namespaces, options)
  end

  # Call node
  defp find({{:., _meta1, args1}, _meta2, args2} = ast_node, namespaces, options) do
    Log.call_node(ast_node)

    continue(args1 ++ [args2], namespaces, options)
  end

  # Unknown node
  defp find({_token, _metadata, args} = ast_node, namespaces, options) do
    Log.unknown_node(ast_node)

    continue(args, namespaces, options)
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

  defp build_module_reference(node, current_module, options, reference_extra_namespace \\ []) do
    module_name =
      node
      |> extract_module_name()
      |> replace__MODULE__mentions(current_module)

    # Extra namespace is used for aliases pointing to multiple modules
    module_full_name =
      reference_extra_namespace
      |> replace__MODULE__mentions(current_module)
      |> Enum.concat(module_name)

    # TODO: Extract this to somewhere else
    # this logic handles aliased modules like:
    # alias Foo.Bar
    # Bar.Batz.some_function()
    root_module_from_name = List.first(module_full_name)
    matched_alias = options.aliases[root_module_from_name]
    module_full_name = if matched_alias do
      matched_alias ++ tl(module_full_name)
    else
      module_full_name
    end

    {_token, [line: line_of_code], _args} = node

    ModuleReference.build(%{
      from: current_module,
      to: module_full_name,
      line: line_of_code,
      file_path: options.file_path
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

  defp continue(args, namespaces, options) do
    args
    |> List.wrap()
    |> Enum.flat_map(fn node -> find(node, namespaces, options) end)
  end

  defp concat_reference_and_continue(args, references, namespaces, options) do
    args
    |> continue(namespaces, options)
    |> Enum.concat(references)
  end

  require IEx
  # If the block is closed, do nothing
  defp add_aliases_if_block_is_open(%{open_alias_block?: false, aliases: aliases}, _references) do
    IEx.pry()
    aliases
  end

  defp add_aliases_if_block_is_open(options, references) when is_list(references) do
    new_aliases = for ref <- references, into: %{}, do: {List.last(ref.to), ref.to}
    IEx.pry()
    Map.merge(options.aliases, new_aliases)
  end

  defp add_aliases_if_block_is_open(options, reference) do
    IEx.pry()
    Map.put(options.aliases, List.last(reference.to), reference.to)
  end
end
