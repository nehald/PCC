defmodule Tx do
  use GenServer
  require IEx
  # Client API

  def tx_send(pid, msg) do
    GenServer.cast(pid, {:send, msg})
  end

  #
  def start_link(args) do
    GenServer.start_link(__MODULE__, args, [])
  end

  def pid_to_string(pid) do
    pid_list = :erlang.pid_to_list(pid)
    pid_string = List.to_string(pid_list) 
    pid_string
 end

  def string_to_pid(pidstr) do
    pid_list = String.to_charlist(pidstr)
    pid = :erlang.pid_to_list(pid_list)
  end

  def _bcast(channel_list_item, msg) do
    {:ok, channel, topic_name} = channel_list_item
    ok = PhoenixClient.Channel.push_async(channel, "shout", msg)
  end

  def bcast(channel_list, msg) do
    channel_sent = Enum.map(channel_list, fn c -> _bcast(c, msg) end)
  end

  def _join(socket_opts, topic) do
    {:ok, socket} = PhoenixClient.Socket.start_link(socket_opts)
    :timer.sleep(1000)
    {:ok, response, channel} = PhoenixClient.Channel.join(socket, topic)
    {:ok, channel, topic}
  end

  def has_extra_channels(state) do
    ec= Map.get(state,"extra_channels")
    case ec do 
    nil ->
	[]
    value ->
        ec
    end 
   end   

  ## Server Callbacks
  #
  def init(state) do
    # """
    #  %{      
    #  :current_user => "user:nehal.desaix@aero.org",
    #   :user_id => #PID<0.589.0>,
    #   :user_topic => "topic:user:nehal.desaix@aero.org",
    #   "extra_channels" => ["topic:missileroom"],
    #   "name" => "GOES 15",
    #   "visible" => 0
    # }
    # """
    topics = [Map.get(state, :user_topic)] ++ has_extra_channels(state)
    
    name = Map.get(state, :name)
    
    ###  remove pid .. because pids don't serialize
    {_, state_new} = Map.pop(state, "extra_channels")
    {_, state_new} = Map.pop(state_new, :user_id)
    {_, state_new} = Map.pop(state_new, :user_graph_id)
   
    socket_opts = [
      url: "ws://localhost:4000/socket/websocket",
      params: state_new
    ]

    ### subscribe to extra channels 
    channel_list = Enum.map(topics, fn c -> _join(socket_opts, c) end)

    state = %{
      :current_user => Map.get(state,:current_user), 
      :socket => socket_opts,
      :channel_list => channel_list,
      :name => name,
      :status => :up
    }
    IEx.pry 
#   channel_list: [{:ok, #PID<0.612.0>, "user:nehal.desaix@aero.org:topic"}],
#   current_user: "user:nehal.desaix@aero.org",
#   name: nil,
#   socket: [
#      url: "ws://localhost:4000/socket/websocket",
#      params: %{
#         current_user: "user:nehal.desaix@aero.org",
#         user_topic: "user:nehal.desaix@aero.org:topic"
#     }
#   ],
#  status: :up
#  }
    {:ok, state}
  end

  def handle_info(%PhoenixClient.Message{} = msg,state) do
    {:noreply, state}
  end

  def handle_info(msg,state) do
    IO.puts inspect msg
    {:noreply,state}
  end 

  def handle_cast({:add_channel,channel_name},state) do
  state =  
   socket_opts = [
      url: "ws://localhost:4000/socket/websocket",
      params: state 
    ]
     
 
  end 

  ## the msg is the full packet
  def handle_cast({:test, _}, state) do
    {:noreply, state}
  end

  ## send info to the channels 
  def handle_cast({:send_async, msg}, state) do
    channel_list = Map.get(state, :channel_list)
    sent = bcast(channel_list, msg)
    {:noreply, state}
  end

  def handle_call({:send,msg}, _from, state) do
    channel_list = Map.get(state, :channel_list)
    sent = bcast(channel_list, msg)
    {:reply, sent, state}
  end

  def handle_call(:status, _from, state) do
    channel = Map.get(state, :channel)
    ok = PhoenixClient.Channel.push_async(channel, "shout", %{})
    {:reply, %{}, state}
  end

  def handle_call(:change_status, _from, state) do
    {:noreplay, state}
  end
end
