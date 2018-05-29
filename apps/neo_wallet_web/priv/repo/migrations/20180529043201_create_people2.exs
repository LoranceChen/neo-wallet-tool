defmodule NeoWalletWeb.Repo.Migrations.CreatePeople2 do
  use Ecto.Migration

  def change do
    create table(:people2) do
      add :first_name, :string
      add :last_name, :string
      add :age, :integer
    end
  end
end
