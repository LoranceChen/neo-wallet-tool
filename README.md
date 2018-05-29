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
  - edit config file: `apps/neo_wallet_web/config/config.exs`
	- mysql connection
	- `cowboy_port`: the app listening port
	- `neo_server`: neo http rpc server address 
  - create database: `mix ecto.create`
  - init database: `mix ecto.migrate`
- run server: `iex -S mix`

