defmodule CCUtils do
  require IEx
  ## system can equal :pos or :tx


  


  defp _get_status({:status, sub_system}, state) do
    sub_pid = Map.get(state, sub_system)
    status = GenServer.call(sub_pid, :status)
    status
  end

  defp _change_status({:change_status, system}, state) do
    sub_pid = Map.get(state, system)
    status = GenServer.call(sub_pid, :change_status)
    status
  end

  ## code that send msg to the chatroom
  defp transmit(msg, state) do
    sat_tx_pid = Map.get(state, :sat_tx_pid)

    case Map.get(msg, "dist") do
      "chat" ->
        GenServer.call(sat_tx_pid, {:chatroom, msg})
      "dm" ->
        {:ok, {:satresp, msg}}
    end
  end

  def status(packet, state) do
    delay_time = :os.system_time(:millisecond)
    ## do something with data
    ## decode msg from other sats or the gs
    ## who's it from and what type of msg
    ## the msg should contain the 'from' and/or 'to'
    from = Map.get(packet, :from)
    msg_data = Map.get(packet, :data)
    satname = Map.get(state, :satname)
    dist = Map.get(packet, :dist)

    ## 
    case msg_data do
      {:status, system} ->
        status = _get_status({:status, system}, state)

        msg = %{
          "timestamp" => delay_time,
          "satname" => satname,
          "msgtype" => "status",
          "value" => status,
          "dist" => dist
        }
        transmit(msg, state)

      {:change_status, system} ->
        status = _change_status({:status, system}, state)

        msg = %{
          "timestamp" => delay_time,
          "satname" => satname,
          "msgtype" => "status_change",
          "value" => status
        }

        transmit(msg,state) 

    end
  end


  def pos(packet, state) do
    msg_data = Map.get(packet, :data)
    from = Map.get(packet, :from)
    satname = Map.get(state, :satname)
    dist = Map.get(packet, :dist)
  end

  
  def create_packet(dest,msg,delay) do
    whereis = Swarm.registered
    inverse_whereis =  Map.new(whereis, fn{k,v} -> {v,k} end)
    packet = %{
      :recv_time => :os.system_time(:millisecond),
      :delay=>delay,
      :data => msg,
      :source => Swarm.whereis_name(self()),
      :dest => dest
    }
     end

end 
