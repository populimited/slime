defmodule Slime.Mixfile do
  use Mix.Project

  @version "1.2.1"

  def project do
    [
      app: :slime,
      build_embedded: Mix.env() == :prod,
      deps: deps(),
      description: """
      An Elixir library for rendering Slim-like templates.
      """,
      elixir: "~> 1.14",
      package: package(),
      source_url: "https://github.com/slime-lang/slime",
      start_permanent: Mix.env() == :prod,
      compilers: [:erlang, :elixir, :app],
      elixirc_paths: elixirc_paths(Mix.env()),
      version: @version,
      extra_applications: [:eex]
    ]
  end

  def application do
    [
      applications: [:eex]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "dialyzer_checks"]
  defp elixirc_paths(_), do: ["lib"]

  def package do
    [
      maintainers: ["Sean Callan", "Alexander Stanko"],
      files: [
        "lib",
        "src/slime_parser.peg.eex",
        "src/slime_parser_transform.erl",
        "mix.exs",
        "README*",
        "LICENSE*",
        "CHANGELOG*"
      ],
      licenses: ["MIT"],
      links: %{github: "https://github.com/slime-lang/slime"}
    ]
  end

  def deps do
    [
      # Benchmarking tool
      {:benchfella, ">= 0.0.0", only: [:dev, :test], runtime: false},
      # Documentation
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      # Automatic test runner
      {:mix_test_watch, ">= 0.0.0", only: :dev, runtime: false},
      # Style linter
      {:credo, ">= 0.0.0", only: [:dev, :test]},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
      # HTML generation helpers
      {:phoenix_html, "~> 2.14", only: :test}
    ]
  end
end
