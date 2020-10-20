defmodule ElixirDetective.Code.Tracers.AliasReferenceTracer do
  alias ElixirDetective.Code.AnalysisServer
  alias ElixirDetective.Code.ModuleReference

  def trace({:alias_reference, meta, module}, env) do
    # Only registers the reference if the module is inside the app namespace this
    # avoids us logging things like Elixir standard library modules as dependencies
    if !!env.file and !!module and !!env.module do
      reference =
        ModuleReference.build(%{
          from: clean_module_name(env.module),
          to: clean_module_name(module),
          file_path: env.file,
          line: meta[:line]
        })

      AnalysisServer.record_reference(reference)
    end

    :ok
  end

  def trace(_event, _env) do
    :ok
  end

  defp split_module_name(module) do
    module
    |> to_string()
    |> String.split(".")
  end

  defp clean_module_name(nil), do: raise "foo"
  defp clean_module_name(module) do
    ["Elixir" | name] = split_module_name(module)
    Enum.join(name, ".")
  end
end
