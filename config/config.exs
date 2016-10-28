use Mix.Config

# import_config "#{Mix.env}.exs"

config :peerage, via: Peerage.Via.Dns
config :peerage, interval: 10

# PollDns config:
config :peerage, dns_name: "localhost"
config :peerage, app_name: "peerage"
