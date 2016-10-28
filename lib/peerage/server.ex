defmodule Peerage.Server do

  @callback poll() :: any

  defmacro __using__(_) do
    quote do
      use GenServer
      @behaviour Peerage.Server
      
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
      
      def poll,     do: [ :"EMPTY_PEERAGE_IMPL@127.0.0.1" ]
      def interval, do: Application.get_env(:peerage, :interval, 10)

      defoverridable [ poll: 0, interval: 0 ]
      
      defp discover do
        poll
        |> only_fresh_node_names
        |> Enum.map(&( [&1, Node.connect(&1)] ))
        |> IO.inspect # probably TODO add verbosity switch
      end
      
      defp only_fresh_node_names(ps) do
        MapSet.difference( MapSet.new(ps), MapSet.new(Node.list) )
        |> MapSet.to_list
      end

    end
  end
  
end
