defmodule Peerage.Via.Dns do
  use Peerage.Server

  @moduledoc """
  Use Dns-based service discovery to connect Nodes.

  ### Example
      config :peerage, via: Peerage.Via.Dns, 
        dns_name: "localhost", 
        app_name: "myapp" 
  
  Will look up the ip(s) for 'localhost', and then try to
  connect to `myapp@$IP` for each returned ip.
  
  Context and resources
  - This project's README
  - [SkyDNS announcement](https://blog.gopheracademy.com/skydns/)
  - [Kubernetes DNS for service discovery](http://kubernetes.io/docs/admin/dns/)
  """
  
  def poll, do: lookup |> to_names([])

  # erlang dns lookup
  defp lookup,    do: lookup String.to_charlist(hostname)
  defp lookup(c), do: :inet_res.lookup(c,:in,:a)

  # turn list of ips into list of node names
  defp to_names([{a,b,c,d} | rest], acc) when is_list(acc) do    
    to_names rest, [:"#{app_name}@#{a}.#{b}.#{c}.#{d}"] ++ acc
  end
  defp to_names([], lst), do: lst
  defp to_names(err,[]),  do: IO.inspect(["dns err",err]); []

  # get config
  defp app_name do
    Application.get_env(:peerage, :app_name, "nonode")
  end
  defp hostname do
    Application.get_env(:peerage, :dns_name, "localhost")
  end
end
