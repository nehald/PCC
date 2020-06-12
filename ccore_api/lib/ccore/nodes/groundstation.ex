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
    GenServer.start_link(__MODULE__, args, [name])
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

    state = Map.put(state,:connections,[])
    
    {:ok, state}
  end

  def handle_call({:add_connection, pid}, _from, state) do
    conns = Map.get(state, :connections)
    new_conns = conns++[pid]
    new_state = Map.put(state, :connections, new_conns)
    {:reply, new_state, new_state}
  end

  def send_info(pid) do 
       GenServer.call(pid,:info)  

  end 
  def handle_call({:send,msg},_from,state) do 
    connections = Map.get(state,:connections)
    num_connection = Enum.count(connections) 
    cond do
      num_connection > 0 -> 
          case msg do 
            "info" ->
                   Enum.map(connections, fn c -> send_info(c) end)  
          end 
      end 
   end

  def handle_call(msg, _from,state) do
    IO.puts(inspect(state))
    {:noreply, state}
  end
end
