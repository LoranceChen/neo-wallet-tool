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
    response = get_utxos_response(address)
    
    send_resp(conn, 200, Poison.encode!(response))
  end

  get "/utxos" do
    address = fetch_query_params(conn).params["address"]
    response = get_utxos_response(address)
    # IO.puts address
    send_resp(conn, 200, Poison.encode!(response))
  end

  
  match(_, do: send_resp(conn, 404, "Oops!\n"))

  defp get_utxos_response(address) do
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
	spentBlock: -1, # data[:block],
	spentTime: "", # data[:spentTime],
	createTime: Integer.to_string(data[:spentTime]),
	gas: data[:gas],
  }
    end)

    
    %{state: 200, result: formatted}
  end
  
end
