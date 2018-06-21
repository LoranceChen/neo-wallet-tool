defmodule NeoWalletWeb.Repo.Migrations.CreateTableTranscationHistory do
  use Ecto.Migration

  def up do
    create table(:transcation_history, primary_key: false) do
      add :txid, :string #, primary_key: true
      add :n, :integer #, primary_key: true
      add :type, :string #, primary_key: true
      add :asset_id, :string #, primary_key: true
      add :create_timestamp, :integer
      add :from, :string
      add :to, :string
      add :value, :integer
      add :gas_consumed, :string
      add :vmstate, :string
      add :block, :integer

      timestamps()
    end

    create index(:transcation_history, [:from])
    create index(:transcation_history, [:to])
    create index(:transcation_history, [:create_timestamp])

    # txid and n should be primary key
    create index(:transcation_history, [:txid])
    create index(:transcation_history, [:n])

  end

  def down do
    drop table(:transcation_history)
  end
end
