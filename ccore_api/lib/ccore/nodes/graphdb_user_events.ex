defmodule CCore.GraphDbUserEvents do
  use GenServer, restart: :permanent
  require IEx  
  @topics :graphdb

  alias EventBus, as: Events


  def start_link(state) do
    event_topic = String.to_atom(state.current_user <> ":graphdb")
    event_topic = :graphdb
    new_state = Map.put(state,:event_topic,event_topic)  
    GenServer.start_link(__MODULE__, new_state, name: Test)
  end

  def init(state) do
    ###tx process requires 
    ##
    event_topic = Map.get(state,:event_topic)
    Events.register_topic(event_topic)
    Events.subscribe({__MODULE__, [event_topic]})
    {:ok,state}  
   end


  def process({_topic,_id} = event) do
   IEx.pry
  end  

  def handle_cast({topic,id} = event,state) do
   IEx.pry
   {:noreply,state} 
  end 


end
