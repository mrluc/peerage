defmodule Peerage.Via.DnsTest do
  use ExUnit.Case
  import ExUnit.CaptureLog

  @app :a1234

  defmodule M do
    def f, do: "your key is 1234. write it down."
  end

  def setup do
    delete_all_env(@app)
    :ok
  end

  test "Peerage.Via.Dns.poll logs connection" do
    Application.put_env(:peerage, :dns_name, "localhost")
    Application.put_env(:peerage, :app_name, "peerage")
    # note: if you're not connected to a network this won't work.
    #  it's dns resolution...
    fun = &Peerage.Via.Dns.poll/0
    assert capture_log(fun) =~ "resolved"
  end

  test "Peerage.Via.Dns.poll doesn't log connection if log_results set to false" do
    Application.put_env(:peerage, :dns_name, "localhost")
    Application.put_env(:peerage, :app_name, "peerage")
    Application.put_env(:peerage, :log_results, false)
    # note: if you're not connected to a network this won't work.
    #  it's dns resolution...
    fun = &Peerage.Via.Dns.poll/0
    assert capture_log(fun) == ""
  end

  defp delete_all_env(app) do
    app
    |> Application.get_all_env()
    |> Enum.each(fn {k, _} ->
      Application.delete_env(app, k)
    end)
  end
end
