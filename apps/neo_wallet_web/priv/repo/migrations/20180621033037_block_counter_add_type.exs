defmodule NeoWalletWeb.Repo.Migrations.BlockCounterAddType do
  use Ecto.Migration
  import Ecto.Query, only: [from: 2]

  def up do
    alter table(:block_counter) do
      add :type, :string

    end

    flush()

    create index(:block_counter, [:type])

    flush()

    initCount = %NeoWalletWeb.Dao.BlockCounter{current_count: -1, type: "invocation_transcation"}
    NeoWalletWeb.Repo.insert(initCount)
  end

  def down do
    q = from(
      b in NeoWalletWeb.Dao.BlockCounter,
      where: b.type == "invocation_transcation"
    )
    NeoWalletWeb.Repo.delete_all(q)

    flush()

    alter table(:block_counter) do
      remove(:type)
    end


  end
end
