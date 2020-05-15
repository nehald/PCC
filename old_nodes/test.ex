defmodule CC.Gs do
  use GenServer

  def start_link(name) do
    GenServer.start_link(__MODULE__, name, [])
  end

  # # Server Callbacks
  def init(args) do
    {name, room} = args
    ## register the gs tx process
    Swarm.register_name(name, self())
    {:ok, gs_tx_pid} = Tx.start_link(args)
    name_tx = name <> ":tx"
    state = %{:gs_tx_pid => gs_tx_pid, :satname => name}
    Swarm.register_name(name_tx, gs_tx_pid)
     
    ## create node in graphdb
    g = Swarm.whereis_name("GraphDB")
    GenServer.cast(g,{:add_edge,name,name_tx})
    newstate = Map.put(state,:GraphDB,g)
    {:ok, newstate}

  end
end
