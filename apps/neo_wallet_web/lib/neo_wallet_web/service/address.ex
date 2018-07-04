defmodule NeoWalletWeb.Service.Address do
  use GenServer

  import Ecto.Query, only: [from: 2]

  def start_link(_opt) do
    GenServer.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    ref = :ets.new(:neo_token, [
      :named_table,
      :set,
      :public,
      read_concurrency: true,
      write_concurrency: true
    ])
    init_token()

    {:ok, ref}
  end

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

      integerValue = String.to_integer(rawValue)
      floatDivDicimal = integerValue / :math.pow(10, String.to_integer(decimal))
      formatStrValue = :erlang.float_to_binary(floatDivDicimal)

      valueStr = cond do
        toAddr == fromAddr -> # 自己转给自己
          "+" <> formatStrValue
        fromAddr == address -> # 花出去了
          "-" <> formatStrValue
        toAddr == address -> # 转给了自己
          "+" <> formatStrValue
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

  # {
  #   data: [
  #     {
  #       hash: //资产的hash
  #       precision: //资产精度。server端从http rpc的invokefunction中获取
  #       symbol: CPX
  #       type: NEP5 //暂时只支持NEP5
  #       imageURL: //logo

  #     },
  #     ...
  #   ]
  # }
  def get_assets() do
    :ets.foldl(fn ({_key, value}, acc) ->
      acc ++ [value]
    end, [], :neo_token)
  end

  defp init_token() do
    # "HexHash,Type,Name,Symbol,Precision,Hash"
    filePath = Path.join(:code.priv_dir(:neo_wallet_web), "resource/neo_token.csv")
    lst = NeoWalletWeb.Util.read_file_lines(filePath)
    IO.puts("neo_token.csv column template - #{List.first(lst)}")

    Enum.each(List.delete_at(lst, 0), fn line ->
      items = String.split(line, ",")

      indexed_items = Stream.with_index(items, 0) |> Enum.to_list
      lineNamedMap = Enum.reduce(indexed_items, %{}, fn ({item, index}, acc) ->
        case index do
          0 ->
            Map.put(acc, :hex_hash, item)
          1 ->
            Map.put(acc, :type, item)
          2 ->
            Map.put(acc, :name, item)
          3 ->
            Map.put(acc, :symbol, item)
          4 ->
            Map.put(acc, :precision, item)
          5 ->
            Map.put(acc, :hash, item)
        end
      end)

      # temp support imageurl
      appendImgURL = Map.put(lineNamedMap, :image_url, "https://i0.wp.com/www.blockchaindk.com/wp-content/uploads/2017/11/NEON-Wallet-Logo.png")
      :ets.insert(:neo_token, {lineNamedMap[:hex_hash], appendImgURL})
    end)
  end

end
