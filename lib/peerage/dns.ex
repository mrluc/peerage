defmodule Peerage.Via.Dns do
  @behaviour Peerage.Provider
  require Logger

  @moduledoc """
  Use Dns-based service discovery to find other Nodes.

  ### Example
      config :peerage, via: Peerage.Via.Dns,
        dns_name: "localhost",
        app_name: "myapp"

  Will look up the ip(s) for 'localhost', and then try to
  connect to `myapp@$IP`.

  You can also specify multiple DNS lookups when you have a
  heterogenous cluster of Nodes, each with their own app name:

      config :peerage, via: Peerage.Via.Dns, dns: [
        [dns_name: "domain-a.ns.svc.clust.local", app_name: "a"],
        [dns_name: "domain-b.ns.svc.clust.local", app_name: "b"]]


  ### Kubernetes

  Kubernetes supports this out of the box for 'headless
  services' -- if you have a service named `myapp`, doing
  `nslookup myapp` in a deployed container will return a
  list of IP addresses for that service.

  More context and resources for using DNS for this:
  - This project's README
  - [SkyDNS announcement](https://blog.gopheracademy.com/skydns/)
  - [Kubernetes DNS for services](http://kubernetes.io/docs/admin/dns/)
  """

  def poll do
    dns_entries()
    |> Enum.map(&(&1[:dns_name] |> lookup() |> to_names([], &1)))
    |> List.flatten()
  end

  defp lookup(hostname) do
    hostname |> String.to_charlist |> :inet_res.lookup(:in, :a)
  end

  # turn list of ips into list of node names
  defp to_names([ip | rest], acc, entry) when is_list(acc) do
    Logger.debug " -> Peerage.Via.Dns resolved '#{entry[:dns_name]}' to #{ to_s(ip) } "
    to_names(rest, [:"#{ entry[:app_name] }@#{ to_s(ip) }" | acc], entry)
  end
  defp to_names([], lst, _entry), do: lst
  defp to_names(err,[], _entry),  do: Logger.error(["dns err",err]); []

  defp dns_entries do
    case Application.fetch_env(:peerage, :dns) do
      :error ->
        [ [dns_name: Application.get_env(:peerage, :dns_name, "localhost"),
           app_name: Application.get_env(:peerage, :app_name, "nonode")]
        ]
      {:ok, entries} ->
        entries
    end
  end

  defp to_s(_ip = {a,b,c,d}), do: "#{a}.#{b}.#{c}.#{d}"
end
