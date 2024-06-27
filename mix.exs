defmodule Slime.Mixfile do
  use Mix.Project

  @version "1.0.0"

  def project do
    [
      app: :slime,
      build_embedded: Mix.env() == :prod,
      deps: deps(),
      description: """
      An Elixir library for rendering Slim-like templates.
      """,
      elixir: "~> 1.17",
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
      applications: [:phoenix_live_view, :phoenix_html, :eex]
    ]
  end

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
      # Documentation
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:phoenix_live_view, "~> 0.20.17"},
      # HTML generation helpers
      {:phoenix_html, "~> 4.1.1"}
    ]
  end
end
