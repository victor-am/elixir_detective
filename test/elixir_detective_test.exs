defmodule ElixirDetectiveTest do
  use ExUnit.Case
  doctest ElixirDetective

  test "greets the world" do
    assert ElixirDetective.hello() == :world
  end
end
