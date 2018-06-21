defmodule NeoWalletWeb.Repo.Migrations.UtxoAddIndex do
  use Ecto.Migration

  def up do
    create index(:utxo, [:is_spent])
  end

  def down do
    drop index(:utxo, [:is_spent])
  end
end
