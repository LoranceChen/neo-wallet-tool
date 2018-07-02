defmodule NeoWalletWeb.Repo.Migrations.RemoveUtxoAssetIndex do
  use Ecto.Migration

  def up do
    drop index(:utxo, [:asset])
  end

  def down do
    create index(:utxo, [:asset])
  end
end
