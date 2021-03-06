defmodule NeoWalletWeb.MixProject do
  use Mix.Project

  def project do
    [
      app: :neo_wallet_web,
      version: "0.1.1",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      applications: [:httpoison,
		     :cowboy,
		     :plug,
         :ecto,
         :logger,
		    ],
      extra_applications: [:logger],
      mod: {NeoWalletWeb.Application, []},
      env: [cowboy_port: 8081],
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [

      {:plug, "~> 1.5.0"},
      {:ecto, "~> 2.0"},
      {:mariaex, "~> 0.8.4"},
      {:poison, "~> 3.1.0"},
      {:httpoison, "~> 1.1"},
      {:cowboy, "~> 2.4.0", override: true},
      {:distillery, "~> 1.5", runtime: false},
      #{:logger_file_backend, "~> 0.0.10"},

	# {:dep_from_hexpm, "~> 0.3.0"},
	# {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
	# {:sibling_app_in_umbrella, in_umbrella: true},
    ]
  end
end
