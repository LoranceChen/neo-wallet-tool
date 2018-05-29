# NeoWalletTool

## Features
- 支持基于address的可用utxo查询
  - eg: `http://localhost:8083/utxos/ARFe4mTKRTETerRoMsyzBXoPt2EKBvBXFX`

## Dependency
- [plug](https://github.com/elixir-plug/plug)
- [ecto](https://github.com/elixir-ecto/ecto)

## Install & Run
- [install elixir](https://elixir-lang.org/install.html)
- init project
  - mix deps.get
- init mysql
  - config mysql connection file `apps/neo_wallet_web/config/config.exs`
  - `mix migrate`
- `iex -S mix`

