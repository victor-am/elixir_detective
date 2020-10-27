defmodule SimpleModule do
  alias MyNamespace.{Module1, Module2}

  def function do
    Module1.Module6.my_function()
  end
end
