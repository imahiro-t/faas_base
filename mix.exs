defmodule FaasBase.MixProject do
  use Mix.Project

  @description "Base library to create AWS Lambda, Azure Functions or IBM Functions"
  @source_url "https://github.com/imahiro-t/faas_base"

  def project do
    [
      app: :faas_base,
      version: "1.2.0",
      elixir: "~> 1.12",
      name: "FaasBase",
      description: @description,
      package: package(),
      build_embedded: true,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      source_url: @source_url,
      docs: [
        main: "readme",
        extras: ["README.md"]
      ]
    ]
  end

  defp package do
    [
      maintainers: ["erin"],
      licenses: ["MIT"],
      links: %{"Github" => @source_url}
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    []
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.4"},
      {:httpoison, "~> 2.2"},
      {:plug_cowboy, "~> 2.7"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end
end
