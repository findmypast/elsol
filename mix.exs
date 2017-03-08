defmodule Elsol.Mixfile do
  use Mix.Project

  def project do
    [app: :elsol,
     version: "0.0.2",
     elixir: "~> 1.0",
     elixir_paths:  ["lib", "lib/elsol"],
     spec_paths: ["spec"],
     spec_pattern: "*_spec.exs",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger, :httpoison]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [ {:espec, "~> 1.1.0", only: :test},
      {:httpoison, "~> 0.11.0"},
      {:poison, "~> 1.3"}
    ]
  end
end
