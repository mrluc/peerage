defmodule Peerage do
  use Application

  @moduledoc """
  Cluster formation, with initial support for 
  dns-based service discovery. Should be usable
  out of the box with Kubernetes (and Convox, when
  using the Weave AMI).
  
  ### Usage

      config :peerage, via: Peerage.Via.$SOME_PROVIDER
  
  There are several providers.

  - `Peerage.Via.Self`
  - `Peerage.Via.List`
  - `Peerage.Via.Dns`

  The List provider is for dev 
  config, so I can easily spin up at least 2 nodes 
  locally in console, and the Dns provider is for 
  production config.
  
  ### Writing Your Own Providers

      defmodule MyWayToFindHomies do
        use Peerage.Server
        def poll, do: [ :"node@somewhere" ]
      end

  And in config:

      config :peerage, via: MyWayToFindHomies

  """

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    cluster_poller = Application.fetch_env!(:peerage, :via)

    # Define workers and child supervisors to be supervised
    children = [
      worker(cluster_poller, [])
    ]

    opts = [strategy: :one_for_one, name: Peerage.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
