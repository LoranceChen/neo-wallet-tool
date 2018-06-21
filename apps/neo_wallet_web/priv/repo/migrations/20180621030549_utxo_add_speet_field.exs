defmodule NeoWalletWeb.Repo.Migrations.UtxoAddSpeetField do
  use Ecto.Migration

  def up do
    alter table(:utxo) do
      add :is_spent, :boolean, default: false, null: false

    end

  end

  def down do
    alter table(:utxo) do
      remove(:is_spent)
    end
  end
end
