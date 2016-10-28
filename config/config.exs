use Mix.Config

# import_config "#{Mix.env}.exs"

config :peerage, via: Peerage.Via.Dns,

  # PollDns config:
  dns_name: "localhost",
  app_name: "peerage"
