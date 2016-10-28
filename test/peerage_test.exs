defmodule PeerageTest do
  use ExUnit.Case
  doctest Peerage

  test "the truth" do
    assert 1 + 1 == 2
  end

  test "Peerage.Via.Dns.poll returns a list of names" do
    Peerage.Via.Dns.poll
  end

  test "Peerage.Via.List initializes" do
    Application.put_env(:peerage, :node_list, some_node_names)
  end

  defp some_node_names, do: [:"nonode@nohost", :"a@127.0.0.1"]
end
