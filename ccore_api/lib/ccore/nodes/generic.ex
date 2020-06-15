defmodule Generic do
  use GenServer
  import Tx
  import CCUtils
  require IEx

  # Client API
  def send(pid, msg) do
    GenServer.call(pid, {:send, msg})
  end

  def start_link(args) do
    name = Map.get(args, "name")
    GenServer.start_link(__MODULE__, args, [name])
  end

  # # Server Callbacks
  def init(state) do
    # %{      
    # :current_user => "user:nehal.desaix@aero.org",
    # :user_graph_id => #PID<0.609.0>,
    # :user_id => #PID<0.601.0>,
    # :user_topic => "user:nehal.desaix@aero.org:topic",
    # "extra_channels" => [],
    # "name" => "45555",
    # "proc_type" => "generic",
    # "visible" => 0
    # }

    name = Map.get(state, "name")
    {:ok, txpid} = Tx.start_link(state)
    {:ok, satprop} = SatPos.start_link(%{:name => name})
    state = Map.put(state, :txpid, txpid)
    state = Map.put(state, :satprop, satprop)
    

    ## put into graphdb
    {:ok, state}
  end

  def handle_call(:info, _from, state) do
    ## forward info request other procs 
    satprop = Map.get(state, :satprop)
    return = GenServer.call(satprop, :info)
    {:replay, return, state}
  end

  def handle_cast(msg, state) do
    IO.puts(inspect(msg))
    txpid = Map.get(state, :txpid)
    GenServer.cast(txpid, "foo")
    {:noreply, state}
  end
end
