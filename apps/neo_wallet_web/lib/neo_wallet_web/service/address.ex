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

      valueStr = cond do
        toAddr == fromAddr -> # 自己转给自己
          "+" <> rawValue
        fromAddr == address -> # 花出去了
          "-" <> rawValue
        toAddr == address -> # 转给了自己
          "+" <> rawValue
      end

      asset_id = data[:asset_id]
      symbol = case data[:type] do
        "NEO" ->
          "NEO"
        "NEP5" ->
          case :ets.lookup(:neo_token, asset_id) do
            [] ->
              "unsupported-symbol"
            [{_, %{symbol: theSymbol}}] ->
               theSymbol
          end

        other ->
          "unsupported-#{other}"
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
        vmstate: data[:vmstate],
        symbol: symbol,
        imageURL: "todo_imageURL",
        decimal: NeoWalletWeb.Service.NeoCliHttp.get_decimal(data[:asset_id]),
      }
    end)

    formatted
  end

  def get_assets_value(address, hash) do
    %{"hash1" => "10"}
  end

end
