defmodule Peerage.Provider do
  @moduledoc "All a Provider needs is a 'poll' method."
  @callback poll() :: any
end

defmodule Peerage.Server do

  @moduledoc """
  Supervised server that polls the configured Provider every so often,
  deduplicating results, compares to already-connected nodes, and
  attempts to `Node.connect/1` to new ones.
  """

  use GenServer
  require Logger

  @default_sync_offset 500

  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(state) do
    Process.send_after(self(), :poll, sync_offset())
    {:ok, state}
  end

  def handle_info(:poll, state) do
    discover()
    Process.send_after(self(), :poll, interval() * 1000)
    {:noreply, state}
  end

  def poll,         do: apply(provider(), :poll, [])
  def interval,     do: Application.get_env(:peerage, :interval, 10)
  def log_results?, do: Application.get_env(:peerage, :log_results, true)

  defoverridable [poll: 0, interval: 0]

  defp discover do
    poll()
    |> only_fresh_node_names
    |> Enum.map(&([&1, connect_to_node(&1)]))
    |> log_results
  end

  defp log_results(ls) do
    if log_results?() do
      table = [["NAME", "RESULT OF ATTEMPT"]] ++ ls
      Logger.debug """
      [Peerage #{vsn()}][ #{provider() }] Discovery every #{interval()}s.

      #{ table |> Enum.map(&log_one/1) |> Enum.join("\n") }

      #{ ["     LIVE NODES", [Atom.to_string(node()), " (self)"]] ++ Node.list
        |> Enum.join("\n     ")
      }
      """
    end
  end
  defp log_one([s,ok]) do
    "     " <> String.pad_trailing("#{s}",20) <> String.pad_trailing("#{ok}",10)
  end
  defp vsn, do: Application.spec(:peerage)[:vsn]

  defp only_fresh_node_names(ps) do
    ps
    |> MapSet.new
    |> MapSet.difference(MapSet.new(Node.list))
    |> MapSet.to_list
  end
  defp provider do
    Application.get_env(:peerage, :via, Peerage.Via.Self)
  end

  defp sync_offset do
    Application.get_env(:peerage, :sync_offset, @default_sync_offset)
  end

  defp connect_to_node(node_name) do
    # Avoid self connecting.
    if node() != node_name do
      Node.connect(node_name)
    else
      true
    end
  end
end


