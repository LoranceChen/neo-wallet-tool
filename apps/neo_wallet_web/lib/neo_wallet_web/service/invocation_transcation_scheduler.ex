defmodule NeoWalletWeb.Service.InvocationTranscationScheduler do
  use GenServer
  alias NeoWalletWeb.Repo
  import Ecto.Query, only: [from: 2]

  # milli seconds
  @breakMilliTime 1000 * 8 * 1
  @switch true
  @neo_server Application.get_env(:neo_wallet_web, :neo_server, "https://tracker.chinapex.com.cn/neo-cli/")

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    # Schedule work to be performed at some point
    do_scheduler()
    {:ok, state}
  end

  def handle_info(:work, state) do
    if @switch do
      IO.puts("#{__MODULE__} do utxo scheduler at - #{inspect(:calendar.local_time())}")
      work()
    end

    # Reschedule once more
    do_scheduler()
    {:noreply, state}
  end

  defp do_scheduler() do
    Process.send_after(self(), :work, @breakMilliTime)
  end

  defp work() do
    # IO.puts "#{__MODULE__}.work begin do scheduler at - #{inspect(:calendar.local_time())}"
    {curUtxoBlock, curITBlock} = __MODULE__.get_current_block_counter_from_db()

    if curITBlock < curUtxoBlock do
      blocks_update_loop(curITBlock + 1, curUtxoBlock)

    end

    # httpInfo = get_blockchain_from_http()
    # currentBlock = Repo. (NeoWalletWeb.Dao.BlockCounter, )
    # IO.puts "#{__MODULE__}.work end do scheduler at - #{inspect(:calendar.local_time())}"
  end

  def get_current_block_counter_from_db() do
    utxoAndIT =
      from(
        b in "block_counter",
        where: is_nil(b.type) or b.type == "invocation_transcation",
        select: {b.current_count, b.type}

      )

    case Repo.all(utxoAndIT, log: false) do
      [{utxoCount, nil}, {itCount, "invocation_transcation"}] ->
        {utxoCount, itCount}
    end
  end

  def get_blockchain_from_http(blockId) do
    neoResponse = HTTPoison.post!(@neo_server, ~s({
	  "jsonrpc": "2.0",
	  "method": "getblock",
	  "params": [#{blockId}, 1],
	  "id": 1
	    }), [{"Content-Type", "application/json"}])

    # IO.puts "#{__MODULE__}.get_blockchain_from_http http response - #{inspect(blockId)}"#, #{inspect(neoResponse)}"

    #  case neoResponse.status_code do
    #    200 -> # success
    bodyStr = neoResponse.body
    bodyMap = Poison.decode!(bodyStr)
    result = bodyMap["result"]
    time = result["time"]
    tx = result["tx"]

    txMap =
      Enum.map(tx, fn tx_item ->
        %{
          txid: tx_item["txid"],
          type: tx_item["type"], # get InvocationTransaction
          vin:
            Enum.map(tx_item["vin"], fn vin ->
              %{txid: vin["txid"], vout: vin["vout"]}
            end),
          vout:
            Enum.map(tx_item["vout"], fn vout ->
              %{
                n: vout["n"],
                asset: vout["asset"],
                value: vout["value"],
                address: vout["address"]
              }
            end),
          gas: tx_item["gas"]
        }
      end)

    formatted = %{
      time: time,
      tx: txMap
    }

    # IO.puts "#{__MODULE__}.get_blockchain_from_http formatted - #{inspect(blockId)}"#, #{inspect(formatted)}"

    formatted
  end

  def block_update_neo_coin(blockChainMap, blockCount) do
    time = blockChainMap[:time]
    tx = blockChainMap[:tx]
    # IO.puts("blockChainMap - #{inspect(blockChainMap)}")
    Enum.each(tx, fn tx_item ->
      txid = tx_item[:txid]
      gas = tx_item[:gas]

      # first vin address
      first_vin = List.first(tx_item[:vin])
      if first_vin != nil do
        first_vin_txid = first_vin[:txid]
        first_vin_vout = first_vin[:vout]

        q = from(
            u in NeoWalletWeb.Dao.UTXO,
            where: u.txid == ^first_vin_txid and u.n == ^first_vin_vout,
            select: u.address
          )

        fromAddress = NeoWalletWeb.Repo.one(q, log: false)

        Enum.each(tx_item[:vout], fn vout ->
          n = vout[:n]
          asset = vout[:asset]
          value = vout[:value]
          address = vout[:address]

          itEntity = %NeoWalletWeb.Dao.TranscationHistory{
            txid: txid,
            n: n,
            type: "NEO",
            asset_id: asset,
            create_timestamp: time,
            from: fromAddress,
            to: address,
            value: value,
            gas_consumed: gas,
            block: blockCount,
          }

          # IO.puts "#{__MODULE__}.block_update_work get utxoEntity - #{inspect(utxoEntity)}"
          case NeoWalletWeb.Repo.get_by(
                NeoWalletWeb.Dao.TranscationHistory,
                [txid: txid, n: n],
                log: false
              ) do
            nil ->
              NeoWalletWeb.Repo.insert(itEntity, log: false)

            # IO.puts "#{__MODULE__}.block_update_work insertUTXO - #{inspect(utxoEntity)}"
            _other ->
              nil
          end
        end)
      end

    end)

  end

  def block_update_nep5_token(blockChainMap, blockCount) do
    time = blockChainMap[:time]
    it_tx = Enum.filter(blockChainMap[:tx], fn tx_item ->
      tx_item[:type] == "InvocationTransaction"
    end)

    it_load = Enum.flat_map(it_tx, fn tx_item ->
      txid = tx_item[:txid]

      get_invocation_tansaction_from_http(txid)
    end)

    # schema "transcation_history" do
    #   field :txid, :string
    #   field :type, :string
    #   field :asset_id, :string
    #   field :create_timestamp, :integer
    #   field :from, :string
    #   field :to, :string
    #   field :value, :integer
    #   field :gas_consumed, :string
    #   field :vmstate, :string
    #   field :block, :integer

    #   timestamps()
    # end
    Enum.each(it_load, fn it_item ->
      data = %NeoWalletWeb.Dao.TranscationHistory{
        txid: it_item[:txid],
        n: it_item[:n], # represent NEP5
        type: "NEP5",
        asset_id: it_item[:contract],
        create_timestamp: time,
        from: it_item[:from],
        to: it_item[:to],
        value: it_item[:value],
        gas_consumed: it_item[:gas_consumed],
        vmstate: it_item[:vmstate],
        block: blockCount
      }

      # check not inserted the NEP5 txid
      case NeoWalletWeb.Repo.get_by(
              NeoWalletWeb.Dao.TranscationHistory,
              [txid: it_item[:txid]],
              log: false
            ) do
        nil ->
          Repo.insert(data, log: false)

        # IO.puts "#{__MODULE__}.block_update_work insertUTXO - #{inspect(utxoEntity)}"
        _other ->
          nil
      end


    end)


    # NeoWalletWeb.Repo.delete_all(NeoWalletWeb.Dao.BlockCounter, log: false)

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
      block_update_neo_coin(blockInfoMap, beginBlock)

      block_update_nep5_token(blockInfoMap, beginBlock)


      # update counter - compelete the block works
      q = from(
        b in NeoWalletWeb.Dao.BlockCounter,
        where: b.type == "invocation_transcation"
      )

      NeoWalletWeb.Repo.update_all(
        q,
        [inc: [current_count: 1]],
        log: false
      )


      # :timer.sleep(1000 * 2)
      # IO.puts "\n=================\n\n\n==================\n"
      blocks_update_loop(beginBlock + 1, toBlock)
    end
  end


  def get_invocation_tansaction_from_http(txid) do
    neoResponse = HTTPoison.post!(@neo_server, ~s({
      "jsonrpc": "2.0",
      "method": "getapplicationlog",
      "params": [#{txid}],
      "id": 1
        }), [{"Content-Type", "application/json"}])

    bodyStr = neoResponse.body
    bodyMap = Poison.decode!(bodyStr)
    result = bodyMap["result"]
    notifications = result["notifications"]
    dataRst = Enum.map(Stream.with_index(notifications, 0), fn {notification, index} ->
      contract = notification["contract"]
      state_value = notification["state"]["value"]
      # nep5 method should be "transfer"
      nep5Method = Enum.at(state_value, 0)
      nep5MethodStr = NeoWalletWeb.Util.hex_to_string(nep5Method)

      loadRst = if nep5MethodStr == "transfer" do
        from = Enum.at(state_value, 1)
        to = Enum.at(state_value, 2)
        value = Enum.at(state_value, 3)

        fromDecoded = NeoWalletWeb.Util.hex_to_addr(from)
        toDecoded = NeoWalletWeb.Util.hex_to_addr(to)
        valueDecoded = NeoWalletWeb.Util.hex_to_integer(value)

        {:ok, %{
            txid: txid,
            n: index,
            vmstate: result["vmstate"],
            contract: contract,
            gas_consumed: result["gas_consumed"],
            from: fromDecoded,
            to: toDecoded,
            value: valueDecoded
        }}
      else
        {:fail, :not_transfer_data}
      end

      loadRst
    end)

    filterRst = Enum.filter(dataRst, fn item ->
      case item do
        {:ok, _} -> true
        {:fail, _} -> false
      end

    end)

    refineFormat = Enum.map(filterRst, fn item ->
      case item do
        {:ok, load} -> load
      end
    end)

    refineFormat
  end

end
