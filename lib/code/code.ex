defmodule ElixirDetective.Code do
  alias ElixirDetective.Code.AST

  def find_module_references(code) do
    AST.find_module_references(code)
  end
end
