defmodule PeerageTest do
  use ExUnit.Case
  doctest Peerage

  test "Peerage.Via.Dns.poll returns a list of names" do
    [ _addr | _rest ] = Peerage.Via.Dns.poll
  end

  #defp some_node_names, do: [:"nonode@nohost", :"a@127.0.0.1"]
end
