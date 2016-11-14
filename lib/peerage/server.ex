defmodule Peerage.Provider do
  @callback poll() :: any
end

defmodule Peerage.Server do
  use GenServer
  require Logger
  
  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end
  
  def init(state) do
    Process.send_after(self(), :poll, 500)
    {:ok, state}
  end
  
  def handle_info(:poll, state) do
    discover
    Process.send_after(self(), :poll, interval * 1000)
    {:noreply, state}
  end
  
  def poll,     do: apply(provider, :poll, [])
  def interval, do: Application.get_env(:peerage, :interval, 10)
  
  defoverridable [ poll: 0, interval: 0 ]
  
  defp discover do
    poll
    |> only_fresh_node_names
    |> Enum.map(&( [&1, Node.connect(&1)] ))
    |> log_results
  end
  
  defp log_results(ls) do
    ls = [["NAME", "RESULT OF ATTEMPT"]] ++ ls
    Logger.debug """
    Peerage.Server has attempted discovery. Results: \n
    #{ ls |> Enum.map(&log_one/1) |> Enum.join("\n") }
    """
  end
  defp log_one([s,ok]) do
    "     "<>String.pad_trailing("#{s}",20) <> String.pad_trailing("#{ok}",10)
  end
  
  defp only_fresh_node_names(ps) do
    MapSet.difference( MapSet.new(ps), MapSet.new(Node.list) )
    |> MapSet.to_list
  end
  defp provider do
    Application.get_env(:peerage, :via, Peerage.Via.Self)
  end
end
