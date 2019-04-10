defmodule Yamlixir.MixProject do
  use Mix.Project

  @project_url "https://github.com/msimonborg/yamlixir"

  def project do
    [
      app: :yamlixir,
      version: "1.0.2",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "YAML parser for Elixir.",
      package: package(),
      aliases: aliases(),
      source_url: @project_url,
      homepage_url: @project_url,
      preferred_cli_env: preferred_cli_env(),
      test_coverage: [tool: ExCoveralls],
      name: "Yamlixir"
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
      {:yamerl, "~> 0.7"},
      {:ex_doc, "~> 0.19.3", only: [:dev, :test]},
      {:excoveralls, "~> 0.10", only: :test},
      {:credo, "~> 1.0.0", only: [:dev, :test], runtime: false},
      {:inch_ex, "~> 2.0", only: [:dev, :test]}
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"Github" => @project_url}
    ]
  end

  defp aliases do
    [
      "yamlixir.build": ["format --check-equivalent", "test", "docs"]
    ]
  end

  defp preferred_cli_env do
    [
      coveralls: :test,
      "coveralls.detail": :test,
      "coveralls.post": :test,
      "coveralls.html": :test,
      "coveralls.travis": :test,
      "coveralls.safe_travis": :test,
      "receiver.build": :test,
      "yamlixir.build": :test
    ]
  end
end
