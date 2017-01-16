defmodule PeerageTest do
  use ExUnit.Case
  doctest Peerage

  test "(r u on wifi?) Dns.poll returns names" do
    # note: if you're not connected to a network this won't work.
    #  it's dns resolution...
    [ _addr | _rest ] = Peerage.Via.Dns.poll
  end

end
