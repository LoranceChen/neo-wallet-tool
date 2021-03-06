# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure your application as:
#
#     config :neo_wallet_web, key: :value
#
# and access this configuration in your application as:
#
#     Application.get_env(:neo_wallet_web, :key)
#
# You can also configure a 3rd-party app:
#
#     config :logger, level: :info
#

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "#{Mix.env}.exs"
use Mix.Config

config :neo_wallet_web, NeoWalletWeb.Repo,
  adapter: Ecto.Adapters.MySQL,
  database: "neo_wallet_tool_v2",
  username: "root",
#  password: "pass",
  hostname: "localhost"

config :neo_wallet_web, cowboy_port: 8084

config :neo_wallet_web, ecto_repos: [NeoWalletWeb.Repo]

config :neo_wallet_web, neo_server: "https://tracker.chinapex.com.cn/neo-cli/"

config :neo_wallet_web, neo_address_version: 23

# config :logger,
#   backends: [:console, {LoggerFileBackend, :error_log}],
#   format: "[$level] $message\n"

# config :logger, :error_log,
#   path: "./info.log",
#   level: :info
