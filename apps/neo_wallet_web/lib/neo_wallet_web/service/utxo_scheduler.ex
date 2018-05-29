defmodule NeoWalletWeb.Service.UtxoScheduler do
  use GenServer
  alias NeoWalletWeb.Repo
  import Ecto.Query, only: [from: 2]
  
  @breakMilliTime 1000 * 5 * 1 # 5min
  @switch true
  @neo_server Application.get_env(:neo_wallet_web, :neo_server, "http://localhost:20332")
  
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    do_scheduler() # Schedule work to be performed at some point
    {:ok, state}
  end

  def handle_info(:work, state) do
    if @switch do
      IO.puts "do utxo scheduler at - #{inspect(:calendar.local_time())}"
      work()
    end
    
    do_scheduler() # Reschedule once more
    {:noreply, state}
  end

  defp do_scheduler() do
    Process.send_after(self(), :work, @breakMilliTime)
  end

  defp work() do
    #IO.puts "#{__MODULE__}.work begin do scheduler at - #{inspect(:calendar.local_time())}"
    currentBlockCount = get_current_block_counter_from_db()
    latestBlockCount = get_block_count_from_http()
    #IO.puts "#{__MODULE__}.work get context - #{currentBlockCount}, #{latestBlockCount}"
    blocks_update_loop(currentBlockCount + 1, latestBlockCount)
    
    #httpInfo = get_blockchain_from_http()
    #currentBlock = Repo. (NeoWalletWeb.Dao.BlockCounter, )
    #IO.puts "#{__MODULE__}.work end do scheduler at - #{inspect(:calendar.local_time())}"
    
  end

  def get_current_block_counter_from_db() do
    query = from b in "block_counter",
      select: b.current_count
    
    case Repo.one(query, log: false) do
      nil -> -1
      count -> count
    end

  end

  def get_blockchain_from_http(blockId) do
    neoResponse = HTTPoison.post!(@neo_server, ~s({
	  "jsonrpc": "2.0",
	  "method": "getblock",
	  "params": [#{blockId}, 1],
	  "id": 1
	    }), [{"Content-Type", "application/json"}])

    #IO.puts "#{__MODULE__}.get_blockchain_from_http http response - #{inspect(blockId)}"#, #{inspect(neoResponse)}"
    
    #  case neoResponse.status_code do
    #    200 -> # success
    bodyStr = neoResponse.body
    bodyMap = Poison.decode!(bodyStr)
    result = bodyMap["result"]
    time = result["time"]
    tx = result["tx"]
    
    txMap = Enum.map(tx, fn(tx_item) ->
      %{
	txid: tx_item["txid"],
	vin: Enum.map(tx_item["vin"], fn(vin) ->
	  %{
	    txid: vin["txid"],
	    vout: vin["vout"],}
	end),
	vout: Enum.map(tx_item["vout"], fn(vout) ->
	  %{
	    n: vout["n"],
	    asset: vout["asset"],
	    value: vout["value"],
	    address: vout["address"]} end)} end)

    formatted = %{
      time: time,
      tx: txMap,
    }

    #IO.puts "#{__MODULE__}.get_blockchain_from_http formatted - #{inspect(blockId)}"#, #{inspect(formatted)}"
    
    formatted
    
  end

  def get_block_count_from_http() do
    httpResponse = HTTPoison.post!(@neo_server, ~s(
	  {
	    "jsonrpc": "2.0",
	    "method": "getblockcount",
	    "params": [],
	    "id": 1
	  }
	),
      [{"Content-Type", "application/json"}]
    )

    body = Poison.decode!(httpResponse.body)
    body["result"]
    
  end

  def block_update_work(blockChainMap, blockCount) do
    time = blockChainMap[:time]
    tx = blockChainMap[:tx]
    Enum.each(tx, fn(tx_item) ->
      txid = tx_item[:txid]
      
      Enum.each(tx_item[:vin], fn(vin) ->
	txid = vin[:txid]
	vout = vin[:vout]
	# remove a item when txid and vout is match
	# ,
	deleteRst = from(u in NeoWalletWeb.Dao.UTXO,
	  where: u.txid == ^txid and u.n == ^vout
	) |> NeoWalletWeb.Repo.delete_all(log: false) # delete one

	#	IO.puts "#{__MODULE__}.block_update_work deleteUTXO - #{inspect(deleteRst)}"
      end)

      
      Enum.each(tx_item[:vout], fn(vout) ->
	n = vout[:n]
	asset = vout[:asset]
	value = vout[:value]
	address = vout[:address]

	utxoEntity = %NeoWalletWeb.Dao.UTXO{
	  address: address,
	  asset: asset,
	  txid: txid,
	  value: value,
	  n: n,
	  spentTime: time,
	  createTime: time,
	  gas: "",
	  block: blockCount,
	}

	#IO.puts "#{__MODULE__}.block_update_work get utxoEntity - #{inspect(utxoEntity)}"
	
	case NeoWalletWeb.Repo.get_by(NeoWalletWeb.Dao.UTXO, [address: address, asset: asset, txid: txid], log: false) do
	  nil ->
	    NeoWalletWeb.Repo.insert(utxoEntity, log: false)
	    # IO.puts "#{__MODULE__}.block_update_work insertUTXO - #{inspect(utxoEntity)}"
	    _other ->
	    nil
	end
	
      end)
      
    end)

    #NeoWalletWeb.Repo.delete_all(NeoWalletWeb.Dao.BlockCounter, log: false)

    
    NeoWalletWeb.Repo.update_all(
      NeoWalletWeb.Dao.BlockCounter,
      [inc: [current_count: 1]],
      log: false
    )

    # todo: this not work at runtime
    # NeoWalletWeb.Repo.update_all(
    #    NeoWalletWeb.Dao.BlockCounter,
      #    inc: [current_count: 1],
      #    log: false
    # )

    # todo: this not works at compile time
    # from(u in NeoWalletWeb.Dao.BlockCounter, inc: [current_count: 1])
    # |> NeoWalletWeb.Repo.update_all(log: false)
    
    
    # NeoWalletWeb.Repo.insert(%NeoWalletWeb.Dao.BlockCounter{current_count: blockCount}, log: false)
    
  end

  def blocks_update_loop(beginBlock, toBlock) do
    
    if(beginBlock < toBlock) do
      blockInfoMap = get_blockchain_from_http(beginBlock)
      block_update_work(blockInfoMap, beginBlock)

      #:timer.sleep(1000 * 2)
      #IO.puts "\n=================\n\n\n==================\n"
      blocks_update_loop(beginBlock + 1, toBlock)
    end
    
    
  end
  
  
end
