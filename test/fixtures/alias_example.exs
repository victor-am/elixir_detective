defmodule SimpleModule do
  alias OtherModule
  alias MyNamespace.YetAnotherModule, as: Mod
  alias MyNamespace.{Module1, Module2}
  alias __MODULE__
  alias __MODULE__.Module3
  # Not supported yet
  alias __MODULE__.{Module4, Module5}
end
