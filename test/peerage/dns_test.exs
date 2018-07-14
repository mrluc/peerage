defmodule Peerage.Via.DnsTest do
  use ExUnit.Case

  def setup do
    delete_all_env(:peerage)
    :ok
  end

  test "dns poll - single" do
    Application.put_env(:peerage, :dns_name, "localhost")
    Application.put_env(:peerage, :app_name, "peerage")
    assert [:"peerage@127.0.0.1"] = Peerage.Via.Dns.poll
  end

  test "dns poll - multiple entries" do
    dns = [
      [dns_name: "localhost", app_name: "a"],
      [dns_name: "localhost", app_name: "b"]
    ]
    Application.put_env(:peerage, :dns, dns)
    assert [:"a@127.0.0.1", :"b@127.0.0.1"] = Peerage.Via.Dns.poll
  end


  defp delete_all_env(app) do
    app
    |> Application.get_all_env
    |> Enum.each(fn {k, _} ->
      Application.delete_env(app, k)
    end)
  end

end
