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
    ###  Sat services  
    state = Map.put(state, :txpid, txpid)
    
    ###  Satellite propogation service 
    state = Map.put(state, :satprop, satprop)
    
    ## put into graphdb
    {:ok, state}
  end

  def handle_call({:sat_info,params}, _from, state) do
    ## forward info request other procs 
    info_type = Map.get(params,"type_info")
    case info_type do 
        "position" ->
	    info_pid = Map.get(state, :satprop)
   	    sat_state = GenServer.call(info_pid, :info)
            IO.puts inspect sat_state
    	    {:reply, sat_state, state}

       "battery" ->
	    info_pid = Map.get(state, :battery)
   	    battery_state = GenServer.call(info_pid, :info)
    	    {:reply, battery_state,state}
    end 
  end

  def handle_cast(msg, state) do
    IO.puts(inspect(msg))
    txpid = Map.get(state, :txpid)
    GenServer.cast(txpid, "foo")
    {:noreply, state}
  end
end
