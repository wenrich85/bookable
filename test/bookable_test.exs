defmodule BookableTest do
  use ExUnit.Case
  doctest Bookable

  test "greets the world" do
    assert Bookable.hello() == :world
  end
end
