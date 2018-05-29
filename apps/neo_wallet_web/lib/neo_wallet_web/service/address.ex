defmodule NeoWalletWeb.Service.Address do

  import Ecto.Query, only: [from: 2]
  
  def get_utxo(address) do
    dbLst = from(u in NeoWalletWeb.Dao.UTXO,
      where: u.address == ^address
    ) |> NeoWalletWeb.Repo.all(log: false)

    Enum.map(dbLst, fn(utxo) ->
      Map.from_struct(utxo)
      |> Map.delete(:__meta__)
      |> Map.delete(:updated_at)
      |> Map.delete(:inserted_at)

    end)
  end

  def test_get_person(id) do
    
    
    NeoWalletWeb.Repo.all(NeoWalletWeb.Dao.Person, [id: id])
  end
  
end

