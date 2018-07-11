# NeoWalletTool

## Features
- 查找钱包地址的所有utxo
  - API: `http://localhost:8084/utxos/{Address}`
- 查找钱包地址的所有交易记录
  - API: `http://localhost:8084/transaction-history/{Address}?beginTime={timestamp}`
- 各种token的基本信息
  - API: `http://localhost:8084/assets`
  
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

