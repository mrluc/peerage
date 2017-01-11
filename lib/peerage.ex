defmodule Peerage do
  use Application

  @moduledoc """
  Peerage is a cluster formation library. It helps your nodes
  find each other and connect, and it tries to keep things simple.

  ### Usage

      config :peerage, via: Peerage.Via.$SOME_PROVIDER

  There are several providers. See the docs on those modules,
  as well as the project README.md, for more information.

  - `Peerage.Via.Self`
  - `Peerage.Via.List`
  - `Peerage.Via.Dns`
  - `Peerage.Via.Udp`

  I use **List** or **Udp** in development, and **Dns** in production.

  ### Custom Providers
  ... are easy! See the code for the included providers.
  If you're just polling something, it can be easy as a module
  with one function:

      defmodule MyWayToFindHomies do
        @behaviour Peerage.Provider         # (optional)
        def poll, do: [ :"node@somewhere" ] # implementation
      end

  And in config:
      config :peerage, via: MyWayToFindHomies

  Have something a bit more complex? If your Provider is an OTP
  process and should be run supervised, just add `serves: true`:

      config :peerage, via: MyWayToFindHomies, serves: true

  `Peerage.Via.Udp`, a GenServer, is a complete example
  of a stateful approach; it uses broadcast, and records nodes it's seen.
  """
  import Supervisor.Spec, warn: false
  def start(_type, _args) do
    opts = [strategy: :one_for_one, name: Peerage.Supervisor]
    Supervisor.start_link(children(serves?()), opts)
  end

  defp children(_srv = false), do: [worker(Peerage.Server,[])]
  defp children(_srv = true),  do: [worker(Peerage.Server,[]), worker(provider(),[])]

  defp provider, do: Application.get_env(:peerage, :via, Peerage.Via.Self)
  defp serves?,  do: Application.get_env(:peerage, :serves, false)
end
