defmodule CCore.GraphDb do
  use GenServer
  require IEx

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  #
  def init(state) do
    [name, socket, channel] = state 
    #g = Graph.new()
    name_graph = "graph:" <> name
    #Swarm.register_name(name_graph, self())

    state = %{
      :socket => socket,
      :channel => channel,
      :name => name_graph,
      :status => :up,
    }

    {{:ok,%{:a=> :b}}, %{:a=> :b}}
  end
end
