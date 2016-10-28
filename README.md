# Peerage

Peerage helps your nodes find each other.

It supports dns-based service discovery, which
means you can use it out of the box with both
Kubernetes and Weave (and probably other things, too).

It's also easy to extend.


## Installation

Add `peerage` to your list of dependencies in `mix.exs`,
and start its application:

```elixir
    def application do
      [applications: [:peerage]]
    end
    
    def deps do
      [{:peerage, "~> 0.1.0"}]
    end
```

## Usage

```elixir
   config :peerage, via: Peerage.Via.$SOME_PROVIDER
```

There are several providers.

- `Peerage.Via.Self` - no-config option that only
  attempts to connect to itself. Not good for much.

- `Peerage.Via.List` - for using a hardcoded list of
  node names. Good for dev environment. See example below.
  
- `Peerage.Via.Dns` - for getting IP addresses from
  DNS. Good for the production config. You can test
  it locally by telling it your app's dns name is
  `localhost`. See example below.
  
- **Custom providers** are simple (but there's more detail below in this doc if you need it). TLDR is:

  ```elixir
      defmodule MyWayToFindHomies do
        use Peerage.Server
        def poll, do: [ :"node@somewhere" ]
      end
  ```
  ```elixir
      config :peerage, via: MyWayToFindHomies
  ```

Usually, I use the List provider in dev 
config, so I can easily spin up at least 2 nodes 
locally in console, and the Dns provider in 
production config, used for releases.

### Peerage.Via.List

```elixir
config :peerage, via: Peerage.Via.List
config :peerage, node_list: [
  :"myapp1@127.0.0.1",
  :"myapp2@127.0.0.1"
]
```
    $ iex --name myapp1@127.0.0.1 -S mix   # one shell
    $ iex --name myapp2@127.0.0.1 -S mix   # other shell

I usually wrap this with a script for launching dev shell and prod release shells, so that I just call `bin/dev 1` or `bin/prod 1`.

### Peerage.Via.Dns

**Minimal dns example, one node:** after installing,
add the following to your config:

```elixir
    config :peerage, via: Peerage.Via.Dns
    config :peerage, dns_name: "localhost"
    config :peerage, app_name: "myapp"
```

And then run iex like this:

    $ iex --name myapp@127.0.0.1 -S mix

It'll use dns to get the IP addresses
for 'localhost', and try to connect to them. In this
case, there'll only be one result, but it's
working; it got that ip by looking up localhost.



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
      dns_name: "myapp",
      app_name: "myapp"  # or k8s-specific FQDN, like
                         # "myapp.myns.svc.myclust.local"
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

