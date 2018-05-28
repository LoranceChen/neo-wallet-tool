defmodule NeoWalletWebTest do
  use ExUnit.Case
  doctest NeoWalletWeb

  test "greets the world" do
    assert NeoWalletWeb.hello() == :world
  end
end
