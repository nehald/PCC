defmodule Sat do
  use GenServer
  import Tx
  import CCUtils
  require IEx

  # Client API
  #
  def start_link(args) do
    GenServer.start_link(__MODULE__, args, [])
  end

  # # Server Callbacks
  #
  def init(state) do
    IO.puts inspect(state) 
    {:ok,txpid} = Tx.start_link(state)
    state = Map.put(state,:txpid,txpid)
   {:ok, state}
  end

  ## delayed receive loop
  ## delay the message from "delay" microseconds
  ## then forward the message to handle_info 
  def handle_call(
        {:receive, pm = %{"from" => name, "delay" => delay, "data" => msg, "dest" => dest}},
        from,
        state
      ) do
    delay = Map.get(pm, "delay")
    data = Map.get(pm, "data")
    dest = Map.get(pm, "dest")

    packet = %{
      :recv_time => :os.system_time(:millisecond),
      :data => data,
      :source => from,
      :dest => dest
    }

    TaskAfter.task_after(delay, fn -> {:receive_nodelay, packet} end, send_result: self())
    {:reply, :ok, state}
  end

  ## actual 'sat' received msg state machine     
  def handle_info({:receive_nodelay, packet}, state) do
    msg_data = Map.get(packet, :data)

    case msg_data do
      {:status, system} ->
        status_ret = status(packet, state)
        {source_pid, _} = Map.get(packet, :source)
        IEx.pry()
        send(source_pid, status_ret)
        {:noreply, state}

      {:pos, _} ->
        pos(packet, state)
        {:norely, state}

      {:test, _} ->
        {source_pid, _} = Map.get(packet, :source)
        IO.puts("foo")
        {:norely, state}
    end
  end

  def handle_cast(msg, state) do
    case msg do
      {:off, :pos} ->
        satpos_pid = Map.get(state, :satpos_pid)
        :sys.suspend(satpos_pid)

      _ ->
        nil
    end

    {:noreply, state}
  end
end
