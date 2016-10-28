defmodule Peerage.Via.Dns do
  use Peerage.Server

  # handle usual alpine, ubuntu and bsd format
  #@nsl_ips ~r/Address( \d)?:\s*(?<ip>\d+\.\d+\.\d+\.\d{1,3})(?!\S)/
  
  def poll, do: lookup |> to_names([])
  
  #defp nslookup do
  #  "nslookup" |> System.cmd( [hostname,server] |> Enum.filter( &is_s/1 ) )
  #end

  defp lookup,                      do: lookup hostname
  defp lookup(s) when is_binary(s), do: lookup String.to_charlist(s)
  defp lookup(c) when is_list(c),   do: :inet_res.lookup(c,:in,:a)

  # turn list of ips into list of node names
  defp to_names([], lst), do: lst
  defp to_names([{a,b,c,d} | rest], acc) when is_list(acc) do    
    to_names rest, [:"#{app_name}@#{a}.#{b}.#{c}.#{d}"] ++ acc
  end
  defp to_names(other,[]) do
    IO.inspect(["DNS LOOKUP ERR",other])
    []
  end
  
  #defp to_names({s, 0}) when is_binary(s) and byte_size(s) > 0 do
  #  IO.inspect %{self: Node.self, peers: Node.list, cmd_out: s}
  #  
  #  String.split(s, "\n", trim: true)
  #  |> Enum.map( &(Regex.named_captures @nsl_ips, &1) )
  #  |> Enum.filter_map( &(&1), &(to_name &1["ip"]) ) # only truthy
  #end
  #defp to_names({out, status}) do
  #  IO.inspect ["Unexpected output", {out, status}]
  #end
  
  #defp to_name(ip) when is_binary(ip) and byte_size(ip) > 0 do
  #  :"#{ app_name }@#{ ip }"
  #end
  #defp to_name(_), do: false

  defp app_name do
    Application.get_env(:peerage, :app_name, "nonode")
  end
  defp hostname do
    Application.get_env(:peerage, :dns_name, "localhost")
  end
  #defp server do
  #  Application.get_env(:peerage, :dns_server, "")
  #end

  # validations
  #defp is_s(s) when is_binary(s) and byte_size(s) > 0, do: s
  #defp is_s(_), do: false
end
