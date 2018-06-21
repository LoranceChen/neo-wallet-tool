defmodule NeoWalletWeb.Dao.TranscationHistory do
  use Ecto.Schema

  @primary_key false
  schema "transcation_history" do
    field :txid, :string
    field :n, :integer # help to identify unique transaction when restart server
    field :type, :string
    field :asset_id, :string
    field :create_timestamp, :integer
    field :from, :string
    field :to, :string
    field :value, :string
    field :gas_consumed, :string
    field :vmstate, :string
    field :block, :integer

    timestamps()
  end
end
