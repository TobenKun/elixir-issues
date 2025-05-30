defmodule Issues.MixProject do
  use Mix.Project

  def project do
    [
      app: :issues,
      escript: escript_config(),
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      name: "Issues",
      source_url: "https://github.com/TobenKun/elixir-issues",
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:httpoison, "~> 1.8"},
      {:poison, "~> 6.0"},
      {:ex_doc, "~> 0.38.1"},
      {:earmark, "~> 1.4"},
      {:excoveralls, "~> 0.18.5", only: :test}
    ]
  end

  defp escript_config do
    [
      main_module: Issues.CLI
    ]
  end
end
