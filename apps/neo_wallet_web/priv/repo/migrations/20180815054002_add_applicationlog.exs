defmodule NeoWalletWeb.Repo.Migrations.AddApplicationlog do
  use Ecto.Migration

  def change do
    create table(:applicationlog, primary_key: false) do
      add :txid, :string, primary_key: true
      add :data, :text
    end

  end
end
