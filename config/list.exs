use Mix.Config
config :peerage, via: Peerage.Via.List, node_list: [
  :"a@127.0.0.1", :"b@127.0.0.1"
]
