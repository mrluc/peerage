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

  def poll, do: lookup() |> to_names([])

  defp lookup do
    hostname() |> String.to_charlist() |> :inet_res.lookup(:in, :a)
  end

  # turn list of ips into list of node names
  defp to_names([ip | rest], acc) when is_list(acc) do
    case log_results?() do
      true -> Logger.debug(" -> Peerage.Via.Dns resolved '#{hostname()}' to #{to_s(ip)} ")
      false -> nil
    end

    to_names(rest, [:"#{app_name()}@#{to_s(ip)}"] ++ acc)
  end

  defp to_names([], lst), do: lst

  defp to_names(err, []) do
    case log_results?() do
      true -> Logger.error(["dns err", err])
      false -> nil
    end

    []
  end

  # helpers
  defp app_name do
    Application.get_env(:peerage, :app_name, "nonode")
  end

  defp hostname do
    Application.get_env(:peerage, :dns_name, "localhost")
  end

  defp log_results? do
    Application.get_env(:peerage, :log_results, true)
  end

  defp to_s(_ip = {a, b, c, d}), do: "#{a}.#{b}.#{c}.#{d}"
end
