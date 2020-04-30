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


  def jjoin(socket_opts,topic) do 
      {:ok, socket} = PhoenixClient.Socket.start_link(socket_opts)
      IEx.pry 
      {:ok, response, channel}=PhoenixClient.Channel.join(socket, topic)
 end

  # # Server Callbacks
  #
  def init(state) do
    """
      %{      
      :current_user => "user:nehal.desaix@aero.org",
       :user_id => #PID<0.589.0>,
       :user_topic => "topic:user:nehal.desaix@aero.org",
       "extra_channels" => ["topic:missileroom"],
       "name" => "GOES 15",
       "visible" => 0
     }
    """

    topics = [Map.get(state, :user_topic)] ++ Map.get(state, "extra_channels")
    name = Map.get(state, :name)

    socket_opts = [
      url: "ws://localhost:4000/socket/websocket"
    ]

    ### subscribe to extra channels 
    channel_list = Enum.map(topics, fn c -> jjoin(socket_opts, c) end)

    state = %{
      :socket => socket_opts,
      :channel => channel_list,
      :name => name,
      :status => :up
    }

    {:ok, state}
  end

  ## the msg is the full packet
  def handle_cast({:test, _}, state) do
    {:noreply, state}
  end

  ## send info to the channels 
  def handle_cast({:send, msg}, state) do
    {:noreply, state}
  end

  #### tx status
  def handle_call(:status, _from, state) do
    channel = Map.get(state, :channel)
    ok = PhoenixClient.Channel.push_async(channel, "shout", %{})
    {:reply, %{}, state}
  end

  def handle_call(:change_status, _from, state) do
    {:noreplay, state}
  end
end
