defmodule NeoWalletWeb.Dao.BlockCounter do
  use Ecto.Schema

  @primary_key false
  schema "block_counter" do
    field :current_count, :integer
    field :type, :string

    timestamps()
  end
end
