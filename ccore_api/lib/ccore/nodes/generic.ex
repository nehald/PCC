defmodule Generic do
  use GenServer
  import Tx
  import CCUtils 
  require IEx

  # Client API
  #
  def start_link(args) do
    GenServer.start_link(__MODULE__, args, [])
  end

  # # Server Callbacks
  def init(state) do
    IEx.pry 
    {:ok, txpid} = Tx.start_link(state)
    state = Map.put(state, :txpid, txpid)
    {:ok, state}
  end

  def handle_cast(msg, state) do
     IO.puts inspect msg 
     txpid=Map.get(state,:txpid)
      
     {:noreply, state}
  end
end
