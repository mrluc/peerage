defmodule PeerageTest do
  use ExUnit.Case
  doctest Peerage

  @app :a1234
  
  defmodule M do
    def f, do: "your key is 1234. write it down."
  end

  def setup do
    delete_all_env(@app)
    :ok
  end

  test "Peerage.Via.Dns.poll returns a list of names" do
    Application.put_env(:peerage, :dns_name, "localhost")
    Application.put_env(:peerage, :app_name, "peerage")
    # note: if you're not connected to a network this won't work.
    #  it's dns resolution...
    [ _addr | _rest ] = Peerage.Via.Dns.poll
  end

  test "Deferred config sanity check" do
    # see DeferredConfig for more extensive usage
    @app |> Application.put_env(:arbitrary, {:apply, {M, :f, []}})
    
    kv = @app
    |> Application.get_all_env
    |> DeferredConfig.transform_cfg

    assert "your key" <> _ = kv[:arbitrary]
    assert {:apply, _} = Application.get_env(@app, :arbitrary)

    kv |> DeferredConfig.apply_transformed_cfg!(@app)
    assert "your key" <> _ = Application.get_env(@app, :arbitrary)
  end

  defp delete_all_env(app) do
    app
    |> Application.get_all_env
    |> Enum.each(fn {k, _} ->
      Application.delete_env(app, k)
    end)
  end

end
