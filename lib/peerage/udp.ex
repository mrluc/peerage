defmodule Peerage.Via.Udp do
  @moduledoc """
  Use UDP multicast to find other nodes.

      config :peerage, via: Peerage.Via.Udp, serves: true
        ip: {0,0,0,0},
        port: 45900,
        multicast_addr: {230,1,1,1}
  
  Will both broadcast and receive node names via UDP on port 45900,
  and keep track of ones it's seen in process state. It's a GenServer,
  so we let Peerage know it needs to be run and
  supervised with `serves: true`.

  `Peerage.Server` periodically calls `poll()`, which is a client
  function for the GenServer's `handle_call(:poll, _, state)`, which 
  returns the seen node names from state.
  
  Only one node can bind the socket, but you can test multiple
  nodes using docker, 
  [like this](https://github.com/docker/docker/issues/3043#issuecomment-51825140)

  For more info on UDP in Elixir, see 
  [this scaleSmall post on multicast UDP in Elixir from 2015](http://dbeck.github.io/Scalesmall-W5-UDP-Multicast-Mixed-With-TCP/),
  especially the explation of gen_udp's `active: N` mode.
  """
  use GenServer
  require Logger
  
  @behaviour Peerage.Provider

  def start_link, do: GenServer.start_link __MODULE__, :ok, name: __MODULE__
  
  def init(:ok) do
    {:ok, socket} = :gen_udp.open port=get_port, [
      :binary, reuseaddr: true, broadcast: true, multicast_loop: true,
      active: 10, multicast_ttl: get_ttl,
      ip: get_ip, add_membership: {maddr=get_maddr, {0,0,0,0}}
    ]
    {:ok, %{seen: MapSet.new(), conn: {maddr, port, socket}}, 0}
  end

  @doc "Client function: `Peerage.Provider` callback. Calls this GenServer."
  def poll, do: GenServer.whereis(__MODULE__) |> do_poll
  defp do_poll(pid) when is_pid(pid), do: GenServer.call(__MODULE__, :poll)
  defp do_poll(_),                    do: IO.puts "(no server)"; []

  @doc "Server function: returns list of node names we've seen."
  def handle_call(:poll, _, state=%{seen: ms}), do: {:reply, MapSet.to_list(ms), state}
  def handle_call(:poll, _, state),             do: {:reply, [], state}
  
  @doc "Broadcast our node name via UDP every 3-7 seconds"
  def handle_info(:broadcast, state=%{conn: {addr, port, sock}}) do
    :ok = :gen_udp.send(sock, addr, port, ["Peer:#{ node }"])
    Process.send_after(self(), :broadcast, :rand.uniform(4_000)+3_000)
    {:noreply, state}
  end
  def handle_info(:timeout, state), do: handle_info(:broadcast, state)
  
  @doc "Handle UDP packet. If it's a node name broadcast, adds to `state.seen`."
  def handle_info({:udp,sock,_,_, "Peer:"<>name}, state=%{seen: ms}) do
    Logger.debug "  -> Peerage.Via.Udp sees: #{ name }"
    :inet.setopts(sock, active: 1)
    {:noreply, %{state | seen: ms |> MapSet.put(name |> String.to_atom)} }
  end
  def handle_info({:udp,sock,_,_,_}, state) do # malformed packet,
    :inet.setopts(sock, active: 1)             # but we'd like not to die.
    {:noreply, state}
  end
  
  def terminate(_,_, %{conn: {_,_,sock}}), do: :gen_udp.close(sock)

  # helpers
  defp get_port,  do: Application.get_env :peerage, :port, 45900
  defp get_ip,    do: Application.get_env :peerage, :ip, {0,0,0,0}
  defp get_maddr, do: Application.get_env :peerage, :multicast_addr, {230,1,1,1}
  defp get_ttl,   do: Application.get_env :peerage, :ttl, 1
end
