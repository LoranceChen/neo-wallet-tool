defmodule NeoWalletWeb.Router do
  use Plug.Router
  use Plug.ErrorHandler

  #  alias Example.Plug.VerifyRequest

  #  plug(Plug.Parsers, parsers: [:urlencoded, :multipart])

  #  plug(
  #    VerifyRequest,
  #    fields: ["content", "mimetype"],
  #    paths: ["/upload"]
  #  )

  #plug Plug.Logger
  plug(:match)
  plug(:dispatch)

  get "/utxos/:address" do
    dataLst = NeoWalletWeb.Service.Address.get_utxo(address)
    formatted = Enum.map(dataLst, fn(data) ->
      %{
	txid: data[:txid],
	block: data[:block],
	vout: %{
	  Address: data[:address],
	  Asset: data[:asset],
	  Value: data[:value],
	  N: data[:n],
	},
	spentBlock: data[:block],
	spentTime: data[:spentTime],
	createTime: data[:spentTime],
	gas: data[:gas],	  
  }
    end)

    
    response = %{state: 200, result: formatted}
    
    send_resp(conn, 200, Poison.encode!(response))
  end
  
  match(_, do: send_resp(conn, 404, "Oops!\n"))
  
end
