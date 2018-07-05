defmodule NeoWalletWeb.Service.Address do

  import Ecto.Query, only: [from: 2]

  def get_utxo(address) do
    dbLst = from(u in NeoWalletWeb.Dao.UTXO,
      where: u.address == ^address and u.is_spent == false
    ) |> NeoWalletWeb.Repo.all(log: false)

    Enum.map(dbLst, fn(utxo) ->
      Map.from_struct(utxo)
      |> Map.delete(:__meta__)
      |> Map.delete(:updated_at)
      |> Map.delete(:inserted_at)

    end)
  end

  def get_transaction_history(address, beginTime, endTime) do
    if String.length(address) == 0 do
      raise "address can't be empty"
    end

    dbLst = from(th in NeoWalletWeb.Dao.TranscationHistory,
      where: th.create_timestamp > ^beginTime and th.create_timestamp <= ^endTime and (th.from == ^address or th.to == ^address),
      order_by: [asc: th.create_timestamp],
      limit: 1000
    ) |> NeoWalletWeb.Repo.all(log: false)

    dataLst = Enum.map(dbLst, fn(th) ->
      Map.from_struct(th)
      |> Map.delete(:__meta__)
      |> Map.delete(:updated_at)
      |> Map.delete(:inserted_at)

    end)

    formatted = Enum.map(dataLst, fn(data) ->
      rawValue = data[:value]
      fromAddr = data[:from]
      toAddr = data[:to]
      decimal = NeoWalletWeb.Service.NeoCliHttp.get_decimal(data[:asset_id])
      asset_id = data[:asset_id]

      {symbol, formatStrValue} = case data[:type] do
        "NEO" ->
          {"NEO", rawValue}
        "NEP5" ->
          case :ets.lookup(:neo_token, asset_id) do
            [] ->
              {"unsupported-symbol", rawValue}
            [{_, %{symbol: theSymbol}}] ->
              {floatValue, _} = Float.parse(rawValue)
              floatDivDicimal = floatValue / :math.pow(10, String.to_integer(decimal))
              formatStrValue = :erlang.float_to_binary(floatDivDicimal, decimals: String.to_integer(decimal))

              readableValue = cutTail(String.to_charlist(formatStrValue)) |> List.to_string
              {theSymbol, readableValue}
          end

        other ->
          {"unsupported-#{other}", rawValue}
      end

      valueStr = cond do
        toAddr == fromAddr -> # 自己转给自己
          "+" <> formatStrValue
        fromAddr == address -> # 花出去了
          "-" <> formatStrValue
        toAddr == address -> # 转给了自己
          "+" <> formatStrValue
      end

      %{
        txid: data[:txid],
        type: data[:type],
        assetId: data[:asset_id],
        time: data[:create_timestamp],
        from: fromAddr,
        to: data[:to],
        value: valueStr,
        gas_consumed: data[:gas_consumed],
        rawValue: rawValue,
        vmstate: data[:vmstate],
        symbol: symbol,
        imageURL: "todo_imageURL",
        decimal: decimal,
      }
    end)

    formatted
  end

  def get_assets_value(address, hash) do
    %{"hash1" => "10"}
  end


  defp cutTail(numberCharList) do
    lastChar = List.last(numberCharList)
    cond do
      lastChar == ?0 ->
        heads = List.delete_at(numberCharList, Enum.count(numberCharList) - 1)
        cutTail(heads)
      lastChar == ?. ->
        heads = List.delete_at(numberCharList, Enum.count(numberCharList) - 1)
        heads
      true -> #ok
        numberCharList
    end

  end


end
