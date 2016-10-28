defmodule Peerage.Mixfile do
  use Mix.Project

  def project do
    [app: :peerage,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     package: package, # # docs
     description: description,
     name: "Peerage",
     source_url: "https://github.com/mrluc/peerage",
     homepage_url: "https://github.com/mrluc/peerage",
     docs: [main: "Peerage", extras: ["README.md"]]]
  end
  
  def description do
    """
    Cluster formation library with support for dns-based 
    discovery which should work on Kubernetes and Weave.
    """
  end

  def package do
    [ # These are the default files included in the package
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Luc Fueston"],
      contributors: ["Luc Fueston"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/mrluc/peerage",}]
  end

  def application do
    [applications: [:logger], mod: {Peerage, []}]
  end
  
  defp deps do
    [{:ex_doc, "~> 0.14", only: :dev}]
  end
end
