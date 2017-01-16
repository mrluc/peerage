defmodule Peerage.Mixfile do
  use Mix.Project

  def project do
    [app: :peerage,
     version: "0.3.4",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     package: package(), # # docs
     description: description(),
     name: "Peerage",
     source_url: "https://github.com/mrluc/peerage",
     homepage_url: "https://github.com/mrluc/peerage",
     docs: [main: "Peerage", extras: ["README.md"]]]
  end

  def description do
    """
    Easy clustering, pluggable discovery: via DNS (for Kubernetes, Weave, discoverd, Swarm and others), UDP multicast, or a plain list of nodes. Easy extensibility for custom Providers.
    """
  end

  def package do
    [ # These are the default files included in the package
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Luc Fueston"],
      contributors: ["Luc Fueston"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/mrluc/peerage",
               "Docs" => "https://hexdocs.pm/peerage/readme.html"}]
  end

  def application do
    [applications: [:logger, :deferred_config], mod: {Peerage, []}]
  end

  defp deps do
    [
      {:deferred_config, "~> 0.1.0"},
      {:ex_doc, "~> 0.14", only: :dev},
      {:credo, "~> 0.5", only: [:dev, :test]},
    ]
  end
end
