defmodule ElixirDetective.MixProject do
  use Mix.Project

  def project do
    [
      app: :elixir_detective,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript(),
      default_task: "escript.build"
    ]
  end

  defp escript do
    [main_module: ElixirDetective]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_cli, "~> 0.1.0"}
    ]
  end
end
