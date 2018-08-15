defmodule NeoWalletWeb.Dao.ApplicationLog do
  use Ecto.Schema

  @primary_key false
  schema "applicationlog" do
    field :txid, :string
    field :data, :string
  end
end
