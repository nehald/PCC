defmodule Generic do
  use GenServer
  import Tx
  import CCUtils 
  require IEx

  # Client API
  def send(pid,msg) do
     GenServer.call(pid,{:send,msg}) 
  end  
 
  def start_link(args) do
    GenServer.start_link(__MODULE__, args, [])
  end

  # # Server Callbacks
  def init(state) do
    {:ok, txpid} = Tx.start_link(state)
    state = Map.put(state, :txpid, txpid)
    IEx.pry 
    {:ok, state}
  end

 def handle_call({:send,msg},_from,state) do
     txpid=Map.get(state,:txpid)
     GenServer.call(txpid,{:send,msg})  
  end 

  def handle_cast(msg, state) do
     IO.puts inspect msg 
     txpid=Map.get(state,:txpid)
     GenServer.cast(txpid,"foo")  
    {:noreply, state}
  end


end
