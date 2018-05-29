defmodule NeoWalletWeb.Service.Address do

  import Ecto.Query, only: [from: 2]
  
  def get_utxo(address) do
    dbLst = from(u in NeoWalletWeb.Dao.UTXO,
      where: u.address == ^address
    ) |> NeoWalletWeb.Repo.all(log: false)

    Enum.map(dbLst, fn(utxo) ->
      rstMap = Map.from_struct utxo
      
      clearMap = rstMap |> Map.delete :__meta__
      clearMap = clearMap |> Map.delete :updated_at
      clearMap = clearMap |> Map.delete :inserted_at

      clearMap
    end)
  end

  def test_get_person(id) do
    
    
    NeoWalletWeb.Repo.all(NeoWalletWeb.Dao.Person, [id: id])
  end
  
end

