defmodule Tx2 do
  use GenServer
  require IEx
  # Client API

  def tx_send(pid,msg) do 
     GenServer.cast(pid,{:send, msg})
  end 


  #
  def start_link(args) do
    GenServer.start_link(__MODULE__, args, [])
  end

  # # Server Callbacks
  #
  def init(init_args) do
   {name,room}= init_args 
   g = Swarm.whereis_name("GraphDB")
   GenServer.cast(g,{:add_edge,name<>":tx",room}) 

   socket_opts = [
      url: "ws://localhost:4000/socket/websocket"
    ]

    {:ok, socket} = PhoenixClient.Socket.start_link(socket_opts)
    :timer.sleep(1000)
    {:ok, response, channel} = PhoenixClient.Channel.join(socket, room)

    state = %{
      :socket => socket,
      :channel => channel,
      :name => name,
      :status => :up
    }

    {:ok, state}
  end

  ## the msg is the full packet


  def handle_cast({:test,_},state) do  
      msg = %{"test" => "a"}
      channel = Map.get(state, :channel)
      :ok = PhoenixClient.Channel.push_async(channel, "shout", msg)
      {:noreply,state} 
  end
 
  def handle_cast({:send, msg}, state) do
    channel = Map.get(state, :channel)
    destination = Map.get(msg, :dest)
    IO.puts inspect  msg 
    case String.slice(destination,-4,4) do
      "room" ->
        current_time = :os.system_time(:millisecond)
        msg = Map.put(msg, :time, current_time)
        case Map.get(state, :status) do
          :up ->
            msg = Map.put(msg, :status, :up)
            IEx.pry 
            :ok = PhoenixClient.Channel.push_async(channel, "shout", msg)
            {:noreply,state} 
          :down ->
            name = Map.get(state, :name)

            down_msg_status = %{
              "current_time" => current_time,
              "name" => name,
              "module" => "tx",
              "status" => :down
            }

            ok = PhoenixClient.Channel.push_async(channel, "shout", msg)
        end

      ## pt 2 pt destination
      _ ->
        IEx.pry
        dest_pid = Swarm.whereis_name(destination)
        current_time = :os.system_time(:millisecond)
        msg = Map.put(msg, :time, current_time)

        case Map.get(state, :status) do
          :up ->
            msg = Map.put(msg, :status, :up)
            send(dest_pid, msg)
        end
    end 
    {:noreply, state}
  end


  #### tx status
  def handle_call(:status, _from, state) do
    channel = Map.get(state, :channel)
    current_time = :os.system_time(:millisecond)
    name = Map.get(state, :name)
    status = Map.get(state, :status)

    tx_status = %{
      "current_time" => current_time,
      "name" => name,
      "module" => "tx",
      "status" => status
    }

    ok = PhoenixClient.Channel.push_async(channel, "shout", tx_status)
    {:reply, status, state}
  end

  def handle_call(:change_status, _from, state) do
    channel = Map.get(state, :channel)
    status = Map.get(state, :status)
    current_time = :os.system_time(:millisecond)
    name = Map.get(state, :name)

    case status do
      :up ->
        newstatus = :down
        state = Map.put(state, :status, newstatus)

        tx_status = %{
          "current_time" => current_time,
          "name" => name,
          "module" => "tx",
          "new_status" => newstatus
        }

        ok = PhoenixClient.Channel.push_async(channel, "shout", tx_status)
        {:reply, newstatus, state}

      :down ->
        newstatus = :up
        state = Map.put(state, :status, newstatus)

        tx_status = %{
          "current_time" => current_time,
          "name" => name,
          "module" => "tx",
          "new_status" => newstatus
        }

        ok = PhoenixClient.Channel.push_async(channel, "shout", tx_status)
        {:reply, newstatus, state}

      _ ->
        {:reply, status, state}
    end
  end

  def handle_cast(msg, state) do
    IO.puts(msg)
  end

  def handle_info(msg, state) do
    case msg do
      _ ->
        {:noreply, state}
    end
  end
end
