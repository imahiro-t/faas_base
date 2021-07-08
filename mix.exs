defmodule FaasBase.MixProject do
  use Mix.Project

  def project do
    [
      app: :faas_base,
      version: "1.0.1",
      elixir: "~> 1.9",
      name: "FaasBase",
      description: description(),
      package: package(),
      build_embedded: true,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      source_url: "https://github.com/imahiro-t/faas_base",
      docs: [
        main: "readme",
        extras: ["README.md"]
      ]
    ]
  end

  defp description do
    "Base library to create AWS Lambda, Azure Functions or IBM Functions"
  end

  defp package do
    [
      maintainers: ["erin"],
      licenses: ["MIT"],
      links: %{"Github" => "https://github.com/imahiro-t/faas_base"}
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    []
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.2"},
      {:httpoison, "~> 1.8"},
      {:plug_cowboy, "~> 2.3"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end
end
