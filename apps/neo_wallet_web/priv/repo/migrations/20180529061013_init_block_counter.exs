defmodule NeoWalletWeb.Repo.Migrations.InitBlockCounter do
  use Ecto.Migration

  def up do
    initCount = %NeoWalletWeb.Dao.BlockCounter{current_count: -1}
    NeoWalletWeb.Repo.insert(initCount)
  end
end
