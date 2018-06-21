defmodule NeoWalletWeb.Service.NeoCliHttp do

  @neo_server Application.get_env(:neo_wallet_web, :neo_server, "http://localhost:20332")

  def get_decimal(nep5_hash) do
  # HTTP response:
  # {
  #     "jsonrpc": "2.0",
  #     "id": 2,
  #     "result": {
  #         "script": "00c108646563696d616c7367f91d6b7085db7c5aaf09f19eeec1ca3c0db2c6ec",
  #         "state": "HALT, BREAK",
  #         "gas_consumed": "0.156",
  #         "stack": [
  #             {
  #                 "type": "Integer",
  #                 "value": "8"
  #             }
  #         ]
  #     }
  # }

    neoResponse = HTTPoison.post!(@neo_server, ~s({
      "jsonrpc": "2.0",
      "method": "invokefunction",
      "params": [
        "#{nep5_hash}",
        "decimals",
        []
        ],
      "id": 2
    }), [{"Content-Type", "application/json"}])

    bodyStr = neoResponse.body
    bodyMap = Poison.decode!(bodyStr)
    result = bodyMap["result"]
    result["stack"][0]["value"]
  end
end
