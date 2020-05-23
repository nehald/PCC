defmodule CCore.User do
  use GenServer
  require IEx

  # Client API
  #
  def start_link(args) do
    GenServer.start_link(__MODULE__, args, [])
  end

  ## start up all the user services 
  def init(state) do
    ## start user channel 
    user_account = "user:" <> state.email
    user_topic = user_account <> ":topic"
    params = %{:current_user => user_account,:user_topic => user_topic}

    socket_opts = [
      url: "ws://localhost:4000/socket/websocket",
      params: params
    ]

    {:ok, socket} = PhoenixClient.Socket.start_link(socket_opts)
    :timer.sleep(1000)
    {:ok, _response, channel} = PhoenixClient.Channel.join(socket, user_topic)

    ## register user process with swarm  
    Swarm.register_name(user_account, self())
    Swarm.register_name(user_topic, channel)

    ### start graphdb.  register the graphdb and save it in the users state 
    user_graph = user_account <> ":graphdb"
    {:ok, graphdb_pid} = CCore.GraphDbUser.start_link(params)
    Swarm.register_name(user_graph, graphdb_pid)
    state = Map.put(state, :graphdb, graphdb_pid)

    ### create links in the graphdb 
    #graphdb_pid = Map.get(state, :graphdb)
  
    GenServer.cast(graphdb_pid, {:add_edge, user_account, user_topic})
    GenServer.cast(graphdb_pid, {:add_edge, user_account, user_graph})

    ## save user state
    state = Map.put(state, :socket, socket)
    state = Map.put(state, :user_topic, user_topic)
    state = Map.put(state, :user_account, user_topic)
    IO.puts(inspect(state))
    {:ok, state}
  end

  def handle_cast({:get_graphdb, _}, state) do
    graphdb = Map.get(state, :graphdb)
    {:reply, {:ok, graphdb}}
  end

  def handle_cast(:get_state, state) do
    {:reply, {:ok, state}}
  end

  def handle_cast({:add_info, key, value}, state) do
    state = Map.put(state, key, value)
    {:noreply, state}
  end

  def handle_in(_msg, _payload, socket) do
    {:noreply, socket}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end
end
