defmodule SimileTest do
  use ExUnit.Case
  doctest Simile

  test "greets the world" do
    assert Simile.hello() == :world
  end
end
