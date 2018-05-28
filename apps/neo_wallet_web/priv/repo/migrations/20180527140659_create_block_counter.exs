defmodule NeoWalletWeb.Repo.Migrations.CreateBlockCounter do
  use Ecto.Migration

  def change do
    create table(:block_counter, primary_key: false) do
      add :current_count, :integer

      timestamps()
    end
    
  end
end
