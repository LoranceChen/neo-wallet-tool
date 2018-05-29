# NeoWalletTool

## Features
- 查找钱包地址可用的utxo
  - eg: `http://localhost:8083/utxos/ARFe4mTKRTETerRoMsyzBXoPt2EKBvBXFX`

## Dependency
- [plug](https://github.com/elixir-plug/plug)
- [ecto](https://github.com/elixir-ecto/ecto)

## Install & Run
- [install elixir](https://elixir-lang.org/install.html)
- init project
  - `mix deps.get`
- init mysql
  - config mysql connection file `apps/neo_wallet_web/config/config.exs`
  - `mix ecto.create`
  - `mix ecto.migrate`
- `iex -S mix`

