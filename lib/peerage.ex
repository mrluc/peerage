defmodule Peerage do
  use Application

  @moduledoc """
  Peerage is a cluster formation library. That is to say, 
  it helps your nodes find each other.

  It supports DNS-based discovery, which means you can use it 
  out of the box with Kubernetes (and probably also Weave, 
  discoverd, Swarm, and other things anything else with 
  dns-based service discovery).
  
  It also supports UDP-based discovery, so that nodes
  on the same network (like docker containers on the 
  same host) can find each other.
  
  It's also easy to extend: adding a new Provider can
  be as simple as writing a single function.
  
  ### Usage

      config :peerage, via: Peerage.Via.$SOME_PROVIDER
  
  There are several providers. See the docs on those modules, 
  as well as the project README.md, for more information.

  - `Peerage.Via.Self`
  - `Peerage.Via.List`
  - `Peerage.Via.Dns`
  - `Peerage.Via.Udp`

  I use **List** or **Udp** in development, and **Dns** in production.
  
  ### Writing Your Own Providers

      defmodule MyWayToFindHomies do
        @behaviour Peerage.Provider         # (optional)
        def poll, do: [ :"node@somewhere" ] # implementation
      end

  And in config:

      config :peerage, via: MyWayToFindHomies
  
  If your Provider is an OTP process and should be
  run supervised, 

      config :peerage, via: MyWayToFindHomies, serves: true
  
  `Peerage.Via.Udp`, a GenServer, is a complete example
  of a more complex, stateful approach; it
  uses broadcast, and records nodes it's seen.
  """

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [ worker(Peerage.Server, []) ]

    children = if serves? do
      children ++ [ worker(provider,[]) ]
    else
      children
    end
    
    opts = [strategy: :one_for_one, name: Peerage.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp provider do
    Application.get_env(:peerage, :via, Peerage.Via.Self)
  end
  defp serves? do
    Application.get_env(:peerage, :serves, false)
  end
end
