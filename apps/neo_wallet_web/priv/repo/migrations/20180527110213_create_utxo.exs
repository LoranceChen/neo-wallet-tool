defmodule NeoWalletWeb.Repo.Migrations.CreateUtxo do
  use Ecto.Migration

  def change do
    create table(:utxo, primary_key: false) do
      add :address, :string #, primary_key: true
      add :asset, :string #, primary_key: true
      add :txid, :string #, primary_key: true
      add :value, :string
      add :n, :integer
      add :spentTime, :integer
      add :createTime, :integer
      add :gas, :string
      add :block, :integer

      timestamps()
    end

    create index(:utxo, [:address])
    create index(:utxo, [:asset])
    create index(:utxo, [:txid])
    create index(:utxo, [:n])
  end
end
