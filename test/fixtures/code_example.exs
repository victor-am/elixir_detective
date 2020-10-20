defmodule MyModule do
  alias OtherModule
  alias MyNamespace.YetAnotherModule, as: Mod
  alias __MODULE__.Module3

  def foo do
    Mod.bar()
    OtherModule.batz()
    Enum.map(%{}, fn x -> x end)
  end

  def bar do
    Module3.some_function()
  end
end
