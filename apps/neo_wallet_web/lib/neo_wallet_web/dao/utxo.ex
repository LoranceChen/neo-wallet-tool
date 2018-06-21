defmodule NeoWalletWeb.Dao.UTXO do
  use Ecto.Schema

  @primary_key false
  schema "utxo" do
    field :address, :string #, primary_key: true
    field :asset, :string #, primary_key: true
    field :txid, :string #, primary_key: true
    field :value, :string
    field :n, :integer
    field :spentTime, :integer
    field :createTime, :integer
    field :gas, :string
    field :block, :integer
    field :is_spent, :boolean

    timestamps()
  end
end

