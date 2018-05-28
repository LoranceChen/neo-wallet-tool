defmodule NeoWalletWeb.Dao.Person do
  use Ecto.Schema
#  use NeoWalletWeb.Dao.BasicSchema
  
  schema "people" do
    field :first_name, :string
    field :last_name, :string
    field :age, :integer

    timestamps()
  end
end

