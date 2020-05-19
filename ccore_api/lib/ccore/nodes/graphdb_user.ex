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

  def graph_into(pid) do
     GenServer.call(pid,{:graph_info,[]})
  end

  # # Server Callbacks
  #
  def init(init_arg) do
    [graph_user, user_account] = init_arg
    state = %{
      :name => user_account, 
      :status => :up,
      :graph => Graph.new() 
    }
   {:ok,state}  
   end
  #

  def handle_cast({:add_node, item}, state) do
    g = Map.get(state, :graph)
    next_g = Graph.add_vertex(g, item)
    msg = %{:key => "add_node", :value => item}
    next_state = Map.put(state, :graph, next_g)
    {:noreply, next_state}
  end

  def handle_cast({:add_node, item, label}, state) do
    g = Map.get(state, :graph)
    next_g = Graph.add_vertex(g, item, label)
    msg = %{:key => "add_node", :value => item}
    next_state = Map.put(state, :graph, next_g)
    {:noreply, next_state}
  end

  def handle_cast({:add_edge, item_a, item_b}, state) do
    g = Map.get(state, :graph)
    next_g = Graph.add_edge(g, item_a, item_b)
    msg = %{:key => "add_edge", :value => %{:s => item_a, :e => item_b}}
    next_state = Map.put(state, :graph, next_g)
    {:noreply, next_state}
  end

  def handle_call({:neighbors, vertex}, _from, state) do
    g = Map.get(state, :graph)
    neighbors = Graph.out_neighbors(g, vertex)
    {:reply, neighbors, state}
  end

  def handle_call({:graph_info, _item}, _from,state) do
    g = Map.get(state, :graph)
    dot = Graph.to_dot(g)
    {:reply,dot,state}
  end


  def handle_info(_msg, state) do
    {:noreply, state}
  end
end
