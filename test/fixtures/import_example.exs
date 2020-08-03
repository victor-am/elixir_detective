defmodule SimpleModule do
  import OtherModule
  import YetAnotherModule, only: [this_method: 2]
end
