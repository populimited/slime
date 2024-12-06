defmodule Slime.Mixfile do
  use Mix.Project

  @version "1.0.0"

  @compile_peg_task "tasks/compile.peg.exs"
  @do_peg_compile File.exists?(@compile_peg_task)

  if @do_peg_compile do
    Code.eval_file(@compile_peg_task)
  end

  def project do
    [
      app: :slime,
      build_embedded: Mix.env() == :prod,
      deps: deps(),
      description: """
      An Elixir library for rendering Slim-like templates.
      """,
      elixir: "~> 1.16",
      package: package(),
      source_url: "https://github.com/slime-lang/slime",
      start_permanent: Mix.env() == :prod,
      compilers: [:peg, :erlang, :elixir, :app],
      elixirc_paths: elixirc_paths(Mix.env()),
      version: @version,
      extra_applications: [:eex]
    ]
  end

  def application do
    [
      applications: [:neotoma, :phoenix_live_view, :phoenix_html, :eex]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  def package do
    [
      maintainers: ["Sean Callan", "Alexander Stanko"],
      files: [
        "lib",
        "src/slime_parser.peg.heex",
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
      # packrat parser-generator for PEGs
      {:neotoma, "~> 1.7.3", manager: :rebar3},
      # Documentation
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:phoenix_live_view, "~> 1.0.0"},
      # HTML generation helpers
      {:phoenix_html, "~> 4.1.1"}
    ]
  end
end
