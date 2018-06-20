defmodule NeoWalletWebTest do
  use ExUnit.Case
  doctest NeoWalletWeb

  test "greets the world" do
    assert NeoWalletWeb.hello() == :world
  end

  test "parse applicationlog: hexString to integer" do
    # doc: http://docs.neo.org/zh-cn/exchange/v2.7.3.html#%E5%A4%84%E7%90%86-nep-5-%E8%B5%84%E4%BA%A7%E4%BA%A4%E6%98%93
    assert NeoWalletWeb.Util.hex_to_integer("00c2eb0b") == 200000000
  end

  test "parse applicationlog: hexString to string address" do
    # doc: http://docs.neo.org/zh-cn/exchange/v2.7.3.html#%E5%A4%84%E7%90%86-nep-5-%E8%B5%84%E4%BA%A7%E4%BA%A4%E6%98%93
    assert NeoWalletWeb.Util.hex_to_addr("2b41aea9d405fef2e809e3c8085221ce944527a7") == "AKibPRzkoZpHnPkF6qvuW2Q4hG9gKBwGpR"
  end
end
