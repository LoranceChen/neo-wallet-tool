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
    dbLst = from(th in NeoWalletWeb.Dao.TranscationHistory,
      where: th.create_timestamp >= ^beginTime and th.create_timestamp <= ^endTime and (th.from == ^address or th.to == ^address),
      order_by: [asc: th.create_timestamp],
      limit: 1000
    ) |> NeoWalletWeb.Repo.all(log: false)

    Enum.map(dbLst, fn(th) ->
      Map.from_struct(th)
      |> Map.delete(:__meta__)
      |> Map.delete(:updated_at)
      |> Map.delete(:inserted_at)

    end)
  end

  def init_token() do
    :ets.delete_all_objects(:neo_token)

    # "HexHash,Type,Name,Symbol,Precision,Hash"
    lst = NeoWalletWeb.Util.read_file_lines("neo_token.csv")
    IO.puts("neo_tracker.csv template - #{List.first(lst)}")

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

      :ets.insert(:neo_token, {lineNamedMap[:hex_hash], lineNamedMap})
    end)
  end

end
