defmodule NeoWalletWeb.Repo.Migrations.CreateBlockCounter do
  use Ecto.Migration

  def up do
    create table(:block_counter, primary_key: false) do
      add :current_count, :integer

      timestamps()
    end

    flush()

    initCount = %NeoWalletWeb.Dao.BlockCounter{current_count: -1}
    NeoWalletWeb.Repo.insert(initCount)
  
  end

  def down do
    drop table(:block_counter)
  end
  

end
