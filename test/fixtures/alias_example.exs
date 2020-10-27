defmodule SimpleModule do
  alias OtherModule
  alias MyNamespace.YetAnotherModule, as: Mod
  alias MyNamespace.{Module1, Module2}
  alias __MODULE__.Module3
  alias __MODULE__.{Module4, Module5}

  def function do
    Module1.Module6.my_function()
    Mod.Module7.another_function(true)
  end
end
