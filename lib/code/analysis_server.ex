defmodule ElixirDetective.Code.AnalysisServer do
  use Agent

  def start_link() do
    initial_value = %{references: [], meta: %{}}
    Agent.start_link(fn -> initial_value end, name: __MODULE__)
  end

  def get_references do
    Agent.get(__MODULE__, fn data -> data.references end)
  end

  def get_meta do
    Agent.get(__MODULE__, fn data -> data.meta end)
  end

  def record_reference(reference) do
    Agent.update(__MODULE__, fn data ->
      %{data | references: data.references ++ [reference]}
    end)
  end

  def set_meta(%{} = meta) do
    Agent.update(__MODULE__, fn data ->
      %{data | meta: meta}
    end)
  end
end
