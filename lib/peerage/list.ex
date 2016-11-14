defmodule Peerage.Via.List do
  @behaviour Peerage.Provider

  @moduledoc """
  Uses configurable list of
  node names. Good for development, or when you know
  production node names ahead of time. See example below.

  ### Example
  
  ```elixir
  config :peerage, via: Peerage.Via.List
  config :peerage, node_list: [
    :"myapp1@127.0.0.1",
    :"myapp2@127.0.0.1"
  ]
  ```
  
      $ iex --name myapp1@127.0.0.1 -S mix   # one shell
      $ iex --name myapp2@127.0.0.1 -S mix   # other shell

  I usually wrap the above with a script for launching dev shell, 
  and prod release shells, so that I just call `bin/dev 1` or 
  `bin/prod 2`.
  """
  
  def poll do
    Application.fetch_env!(:peerage, :node_list)
  end
end
