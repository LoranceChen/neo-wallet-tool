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
    send_resp(conn, 200, Poison.encode!(response))
  end

  get "/transaction-history/:address" do
    beginTime = fetch_query_params(conn).params["beginTime"]
    endTime = fetch_query_params(conn).params["endTime"]


    response = if is_nil(endTime) do
      get_transaction_history_response(address, String.to_integer(beginTime))
    else
      get_transaction_history_response(address, String.to_integer(beginTime), endTime)
    end

    send_resp(conn, 200, Poison.encode!(response))
  end

  get "/transaction-history" do
    address = fetch_query_params(conn).params["address"]
    beginTime = fetch_query_params(conn).params["beginTime"]
    endTime = fetch_query_params(conn).params["endTime"]

    response = if is_nil(endTime) do
      get_transaction_history_response(address, beginTime)
    else
      get_transaction_history_response(address, beginTime, endTime)
    end

    send_resp(conn, 200, Poison.encode!(response))
  end

  get "/assets" do
    assets = NeoWalletWeb.Service.Address.get_assets()
    result = %{state: 200, result: assets}
    send_resp(conn, 200, Poison.encode!(result))
  end

  get "/nep5-value/:address" do
    assets = fetch_query_params(conn).params["assets"]

    

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

  def get_transaction_history_response(address, beginTime, endTime \\ DateTime.to_unix(DateTime.utc_now)) do
    data = NeoWalletWeb.Service.Address.get_transaction_history(address, beginTime, endTime)

    %{state: 200, result: data}
  end
end
