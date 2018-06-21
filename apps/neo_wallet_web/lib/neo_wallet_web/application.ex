defmodule NeoWalletWeb.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    port = Application.get_env(:neo_wallet_web, :cowboy_port, 8080)

    # List all child processes to be supervised
    children = [
      # Starts a worker by calling: NeoWalletWeb.Worker.start_link(arg)
      # {NeoWalletWeb.Worker, arg},
      NeoWalletWeb.Repo,
      NeoWalletWeb.Service.UtxoScheduler,
      NeoWalletWeb.Service.InvocationTranscationScheduler,
      Plug.Adapters.Cowboy2.child_spec(scheme: :http, plug: NeoWalletWeb.Router, options: [port: port]),

    ]

    IO.puts "server listening at: #{port}"

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: NeoWalletWeb.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
