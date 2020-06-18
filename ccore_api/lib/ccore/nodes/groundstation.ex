defmodule Groundstation do
  use GenServer
  require IEx
  # Client API
  def send(pid, msg) do
    GenServer.call(pid, {:send, msg})
  end

  def start_link(args) do
    name = Map.get(args, "name")
    arg = %{:connections => []}
    GenServer.start_link(__MODULE__, args)
  end

  # # Server Callbacks
  def init(state) do
    # %{      
    # :current_user => "user:nehal.desaix@aero.org",
    # :user_graph_id => #PID<0.609.0>,
    # :user_id => #PID<0.601.0>,
    # :user_topic => "user:nehal.desaix@aero.org:topic",
    # "name" => "ksc",
    # "loc" ==> location 
    # "proc_type" => "groundstation",
    # }

    state = Map.put(state, :connections, [])

    {:ok, state}
  end

  def handle_call({:add_connection, pid}, _from, state) do
    conns = Map.get(state, :connections)
     
    new_conns = conns ++ [pid]
    new_state = Map.put(state, :connections, new_conns)
    {:reply, new_state, new_state}
  end

  def _sat_info(pid) do
     satpos = GenServer.call(pid, :sat_info)
     satpos 
  end


  defp get_sat_info(state) do
    connections = Map.get(state, :connections)
    num_connection = Enum.count(connections)
    info_list=Enum.map(connections, fn c -> _sat_info(c) end)
    info_list 
  end


  defp get_connection_info(state) do
    connections = Map.get(state, :connections)
    r_swarm = Map.new(Swarm.registered, fn {key,val} -> {val,key} end) 
    connection_name = Enum.map(connections, fn c -> Map.get(r_swarm,c) end)
    connection_name
  end

   
  def handle_call({:info, msg}, _from, state) do
    case msg do
      "sat_info" ->
        sat_info = get_sat_info(state)
        {:reply,sat_info,state} 
      "connection_info" ->
        c = get_connection_info(state)
        unique_c = Enum.uniq(c) 
        {:reply,unique_c,state}
      _ ->
        IO.puts("msg = " <> msg)
        {:noreply,state}
    end
   end
  

   def handle_call(msg, _from, state) do
    IO.puts(inspect(msg))
    {:noreply, state}
  end
end
