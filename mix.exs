defmodule LinearRegression.MixProject do
  use Mix.Project

  def project do
    [
      app: :linear_regression,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
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
    ]
  end
  defp deps do
    [
      {:nx, "~> 0.2.1"},
      {:nimble_csv, "~> 1.1"},
      {:scholar, "~> 0.1.0", github: "elixir-nx/scholar"}
    ]
 end

end
