defmodule ElixirDetective.Code do
  alias ElixirDetective.Code.{Files, AnalysisServer}
  alias ElixirDetective.Code.Tracers.AliasReferenceTracer

  def find_references(path) do
    Code.compiler_options(%{tracers: [AliasReferenceTracer]})
    AnalysisServer.start_link()

    path
    |> Files.find_files_on_folder(allowed_extensions: ["ex", "exs"])
    |> find_references_from_files()

    AnalysisServer.get_references()
  end

  defp find_references_from_files(files) do
    Kernel.ParallelCompiler.compile(files)
  end
end
