# Peerage

Peerage helps your nodes find each other.

It supports DNS-based discovery, which
means you can use it out of the box with Kubernetes (and 
probably also Weave, discoverd,
Swarm, or other anything else with dns-based service 
discovery).

It also supports UDP-based discovery, so that nodes
on the same network (like docker containers on the 
same host) can find each other.

It's also easy to extend: adding a new Provider can
be as simple as writing a single function.


## Installation

Add `peerage` to your list of dependencies in `mix.exs`,
and start its application:

```elixir
    def application do
      [applications: [:peerage]]
    end
    def deps do
      [{:peerage, "~> 1.0.2"}]
    end
```

Note that the latest hex version may be higher than what is listed here. You can
find the latest version on [hex](https://hex.pm/packages/peerage). You should match
the version or alternatively you can use a looser version constraint like `"~> 1.0"`.

## Usage

Peerage will attempt to `Node.connect/1` to node names returned
by a provider that you choose:

```elixir
   config :peerage, via: Peerage.Via.Dns
```

There are several providers available, each with examples further down the page.

- `Peerage.Via.Self` is a 'hello, world' provider that 
  only connects to itself.
- `Peerage.Via.List` uses a hardcoded list of
  node names. It's good for development, or when you know
  production node names ahead of time. See example below.
- `Peerage.Via.Dns` gets IP addresses from
  DNS. Works for production config on **Kubernetes**; probably
  works on Weave, Flynn, and Swarm. You can test
  it locally with one node by telling it your app's dns name is
  `localhost` (this is also the default). See example below.
- `Peerage.Via.Udp` uses peer-to-peer UDP multicast. Docker
  containers on a single host can use this out of the 
  box (example below). 
  Could be useful in a variety of situations
  where nodes are on the same network/overlay network, providing
  the network doesn't restrict multicast.
- **Custom providers** are simple (but there's more detail below). TL;DR is:
  
  ```elixir
      defmodule MyWayToFindHomies do
        def poll, do: [ :"node@somewhere" ]
      end
  ```
  ```elixir
      config :peerage, via: MyWayToFindHomies
  ```

Usually, I use the List or Udp providers in dev 
config, so I can easily test multiple nodes on my machine,
and the Dns provider for my production releases, which run
in places (like Kubernetes) where nodes can be 
found by DNS discovery.

## Config

Optional config for all apps

```elixir
config :abc, via: SomeProvider,
  serves: false,     # true if provider runs supervised
  interval: 15,      # default 10
  log_results: true  # show connection results in debug mode?
```

See specific providers for their additional config.

## Deferred Config

Supporting release config is easy now.

The `:peerage` app uses
[DeferredConfig](https://hex.pm/packages/deferred_config),
at app startup, so all config for the app (including
any custom providers) automatically supports run-time
config via `{:system, "MY_ENV_VAR"}` tuples (with optional
defaults and conversion functions), as well as arbitrary
functions via MFA tuples. See DeferredConfig for more
details, but the upshot is that everything you want
to be runtime configurable should be.


## Peerage.Via.List

```elixir
config :peerage, via: Peerage.Via.List, node_list: [
  :"myapp1@127.0.0.1",
  :"myapp2@127.0.0.1"
]
```

    $ iex --name myapp1@127.0.0.1 -S mix   # one shell
    $ iex --name myapp2@127.0.0.1 -S mix   # other shell

I wrap this with a script for launching dev shell and prod release shells, so that I just call `bin/dev 1` or `bin/prod 1` to test locally in mix, or a release with env vars set to work on my machine.

## Peerage.Via.Dns

DNS-based discovery is where it's at.

**Minimal dns example, one node:** after installing,
add the following to your config:

```elixir
    config :peerage, via: Peerage.Via.Dns,
      dns_name: "localhost",
      app_name: "myapp"
```

And then run iex like this:

    $ iex --name myapp@127.0.0.1 -S mix

It'll use dns to get the IP addresses
for 'localhost', and try to connect to them. In this
case, there'll only be one result, but it's
working; it got that ip by looking up localhost!



**Longer example:**

Say you have an app called `:myapp`. You're deploying
it to Kubernetes as a headless service with `name: myapp` and `clusterIP: None`.
Or to Convox with the Weave AMI, with an app name of `myapp`.
You launch your application so that its node will
be called `myapp@${NODE_IP}`, with the ip of the container being provided by an overlay network.

- If you're using releases, you'll get that IP in an
  env variable (or just set it yourself on container
  startup), splice that address into `rel/vm.args` with
  a line like `-name ${NODE_NAME}@${NODE_IP}`, and run
  your release with `REPLACE_OS_VARS=true`. (See exrm or
  distillery docs if necessary).
  
Your config/prod.exs might look like this:

```elixir
    config :peerage, via: Peerage.Via.Dns
      dns_name: "myapp", # or k8s FQDN: "myapp.ns.svc.clust.local"
      app_name: "myapp"  
```

Now your app will look up the name "myapp" from within
your container. In Kubernetes, `hostname -i myapp` [will
(as of 1.3 or somesuch)](http://kubernetes.io/docs/admin/dns/) return the list of IP addresses
of each of the pods that make up the service; the same is
true on a system with Weave for container networking.

- If the network name needs to be specified more (perhaps
  the dns discovery supports encoding version 
  numbers, regions, etc into the name, and you 
  want to only connect to the same version), 
  change `dns_name`.

In Kubernetes, you can test all of this with minikube.

## Peerage.Via.Udp

```elixir
  config :peerage, via: Peerage.Via.Udp, serves: true
    port: 45900
```

Will both broadcast and receive node names via UDP on port 45900,
and keep track of ones it's seen so that Peerage connect to them. 
It's a GenServer, so we let Peerage know it needs to be run and
supervised with `serves: true`.

## Custom Providers

For simple cases, where you're polling a source of truth (some API, etc): just provide a `poll` method that returns a list of node-name atoms:

```elixir
defmodule MyWayToFindHomies do
  def poll, do: [ :"name@host" ] # poll source of truth
end
```
```elixir
config :peerage, via: MyWayToFindHomies
```

For more complex, peer-to-peer cases -- say, UDP multicast, where each node is broadcasting itself on the network -- you'll probably want to use a GenServer, listening for incoming broadcast messages, and building up a list of 'seen' nodes over time.

If your Provider is an OTP process, just add `serves: true` to your config:

```elixir
config :peerage, via: MyWayToFindHomies, serves: true
``` 

For a full-fledged example, see `Peerage.Via.Udp`.



