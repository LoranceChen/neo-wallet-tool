defmodule NeoWalletWeb.Service.NeoCliHttp do
  use GenServer

  @neo_server Application.get_env(:neo_wallet_web, :neo_server, "http://localhost:20332")

  def start_link(_opt) do
    GenServer.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    ref = :ets.new(:nep5_hash, [
      :named_table,
      :set,
      :public,
      read_concurrency: true,
      write_concurrency: true
    ])
    {:ok, ref}
  end

  def get_decimal(nep5_hash) do
    case :ets.lookup(:nep5_hash, nep5_hash) do
      [] ->
        neoResponse = HTTPoison.post!(@neo_server, ~s({
          "jsonrpc": "2.0",
          "method": "invokefunction",
          "params": [
            "0x#{nep5_hash}",
            "decimals",
            []
            ],
          "id": 2
        }), [{"Content-Type", "application/json"}])

        bodyStr = neoResponse.body
        bodyMap = Poison.decode!(bodyStr)
        result = bodyMap["result"]
        dicemal = List.first(result["stack"])["value"]
        :ets.insert(:nep5_hash, {nep5_hash, dicemal})
        dicemal
      [{_, dicemal}] ->
        dicemal
    end

  end
end
