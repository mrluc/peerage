defmodule PeerageTest do
  use ExUnit.Case
  doctest Peerage

  test "Peerage.Via.Dns.poll returns a list of names" do
    Application.put_env(:peerage, :dns_name, "localhost")
    Application.put_env(:peerage, :app_name, "peerage")
    # note: if you're not connected to a network this won't work.
    #  it's dns resolution...
    [ _addr | _rest ] = Peerage.Via.Dns.poll
  end

  test "Peerage.Via.Dns supports {:system, [ENV_NAME]} syntax" do
    System.put_env("ENV_DNS_NAME", "localhost")
    System.put_env("ENV_APP_NAME", "peerage")
    Application.put_env(:peerage, :dns_name, {:system, "ENV_DNS_NAME"})
    Application.put_env(:peerage, :app_name, {:system, "ENV_APP_NAME"})
    # note: if you're not connected to a network this won't work.
    #  it's dns resolution...
    [ _addr | _rest ] = Peerage.Via.Dns.poll
  end

  test "Peerage.Via.Dns supports {:system, [ENV_NAME], [DEFAULT]} syntax" do
    Application.put_env(:peerage, :dns_name, {:system, "ENV_DNS_NAME", "localhost"})
    Application.put_env(:peerage, :app_name, {:system, "ENV_APP_NAME", "peerage"})
    # note: if you're not connected to a network this won't work.
    #  it's dns resolution...
    [ _addr | _rest ] = Peerage.Via.Dns.poll
  end

end
