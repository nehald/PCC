defmodule CCore.GraphDbUser do
  use GenServer
  require IEx

  def start_link(state) do
    GenServer.start_link(__MODULE__, state)
  end

  #
  def add_node(pid, vertex) do
    GenServer.cast(pid, {:add_node, vertex})
  end

  def add_edge(pid, vertex1, vertex2) do
    GenServer.cast(pid, {:add_edge, vertex1, vertex2})
  end

  def info(pid) do
    GenServer.cast(pid, {:info, []})
  end

  def out_neighbors(pid, vertex) do
    GenServer.call(pid, {:neighbors, vertex})
  end

  # # Server Callbacks
  #
  def init(init_arg) do
    [gname, user_topic] = init_arg
    g = Graph.new()
    socket_opts = [
         url:  "ws://localhost:4000/socket/websocket"
    ] 

   ###
   IO.puts "graph1"
   {:ok, socket} = PhoenixClient.Socket.start_link(socket_opts)
   :timer.sleep(2000)
   IO.puts inspect Swarm.registered
   {:ok, response, channel} = PhoenixClient.Channel.join(socket,user_topic)
    state = %{
      :socket => socket,
      :channel => channel,
      :name => gname,
      :status => :up,
      :graph => g
    }
   IO.puts inspect(state)
   {:ok,state}  
   end
  #

  def push(msg, state) do
    channel = Map.get(state, :channel)
    :ok = PhoenixClient.Channel.push_async(channel, "bcast", msg)
    {:noreply, state}
  end

  def handle_cast({:add_node, item}, state) do
    g = Map.get(state, :graph)
    next_g = Graph.add_vertex(g, item)
    msg = %{:key => "add_node", :value => item}
    push(msg, state)
    next_state = Map.put(state, :graph, next_g)
    {:noreply, next_state}
  end

  def handle_cast({:add_node, item, label}, state) do
    g = Map.get(state, :graph)
    next_g = Graph.add_vertex(g, item, label)
    msg = %{:key => "add_node", :value => item}
    push(msg, state)
    next_state = Map.put(state, :graph, next_g)
    {:noreply, next_state}
  end

  def handle_cast({:add_edge, item_a, item_b}, state) do
    g = Map.get(state, :graph)
    next_g = Graph.add_edge(g, item_a, item_b)
    msg = %{:key => "add_edge", :value => %{:s => item_a, :e => item_b}}
    push(msg, state)
    next_state = Map.put(state, :graph, next_g)
    {:noreply, next_state}
  end

  def handle_call({:neighbors, vertex}, _from, state) do
    g = Map.get(state, :graph)
    neighbors = Graph.out_neighbors(g, vertex)
    {:reply, neighbors, state}
  end

  def handle_cast({:info, _item}, state) do
    IO.puts(inspect(state))
    {:noreply, state}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end
end
