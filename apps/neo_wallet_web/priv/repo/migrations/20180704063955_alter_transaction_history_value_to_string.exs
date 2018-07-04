defmodule NeoWalletWeb.Repo.Migrations.AlterTransactionHistoryValueToString do
  use Ecto.Migration

  def up do
    alter table(:transcation_history) do
      modify :value, :string
    end
  end

  def down do
    alter table(:transcation_history) do
      modify :value, :integer
    end
  end
end
