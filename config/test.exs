use Mix.Config
config :peerage, via: Peerage.Via.Dns,
  app_name: "peerage", dns_name: "localhost"
