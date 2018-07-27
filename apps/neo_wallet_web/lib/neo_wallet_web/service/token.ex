defmodule NeoWalletWeb.Service.Token do
  use GenServer

  @neo_server Application.get_env(:neo_wallet_web, :neo_server, "https://tracker.chinapex.com.cn/neo-cli/")

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

    ref1 = :ets.new(:neo_token_seq, [
      :named_table,
      :set,
      :public,
      read_concurrency: true,
      write_concurrency: true
    ])
    init_token_seq()

    {:ok, {ref, ref1}}
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
    allAssets = :ets.foldl(fn ({_key, value}, acc) ->
      acc ++ [value]
    end, [], :neo_token)

    # 越小值越大
    Enum.sort(allAssets, fn (asset, asset2) ->
      assetSymbol = asset[:symbol]
      assetSymbol2 = asset2[:symbol]
      priority = case :ets.lookup(:neo_token_seq, assetSymbol) do
        [{_, priority}] ->
          priority
        _other ->
          100000
      end
      priority2 = case :ets.lookup(:neo_token_seq, assetSymbol2) do
        [{_, priority2}] ->
          priority2
        _other ->
          100000
      end
     # IO.puts("allAssets_assetSymbol - #{inspect(asset)}, #{inspect(asset2)}")
     # IO.puts("priproty - #{inspect(priority)} #{inspect(priority2)}")
      priority <= priority2
    end)

  end

  # {
  #   "jsonrpc": "2.0",
  #   "method": "invokefunction",
  #   "params": [
  #     "0x45d493a6f73fa5f404244a5fb8472fc014ca5885",
  #     "decimals",
  #     []
  #     ],
  #   "id": 2
  # }
  def get_values(address, nep5List) do

    httpResponse = HTTPoison.post!(@neo_server, ~s(
	    {
        "jsonrpc": "2.0",
        "method": "invokefunction",
        "params": [
          "0xecc6b20d3ccac1ee9ef109af5a7cdb85706b1df9", # hash of CPX
          "balanceOf",
          [
            {
              "type": "Hash160",
              "value": "0xa7274594ce215208c8e309e8f2fe05d4a9ae412b"
            }
          ]
        ],
        "id": 3
      }
    ), [{"Content-Type", "application/json"}], recv_timeout: 30_000)

  end

  defp init_token() do
    # "HexHash,Type,Name,Symbol,Precision,Hash"
    filePath = Path.join(:code.priv_dir(:neo_wallet_web), "resource/neo_token.csv")
    lst = NeoWalletWeb.Util.read_file_lines(filePath)
    # IO.puts("neo_token.csv column template - #{List.first(lst)}")

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

  defp init_token_seq() do
    filePath = Path.join(:code.priv_dir(:neo_wallet_web), "resource/token_seq.csv")
    lst = NeoWalletWeb.Util.read_file_lines(filePath)

    Enum.each(Enum.with_index(lst), fn {line, index} ->
      items = String.split(line, ",")
      tokenSymbol = List.first(items)
     # IO.puts("tokenSymbol - " <> tokenSymbol <>  " " <> Integer.to_string(index))
      :ets.insert(:neo_token_seq, {tokenSymbol, index})
    end)

  end

end
