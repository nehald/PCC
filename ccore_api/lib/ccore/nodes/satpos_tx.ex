defmodule SatPos do
  use GenServer
  require IEx
  # Client API

  #
  def start_link(data) do
    GenServer.start_link(__MODULE__, data, [])
  end

  # # Server Callbacks
  #
  def init(data) do
    name = Map.get(data, :name)
    pos_url = "http://localhost:5000/sat/position/" <> name

    base_state = %{
      :url => pos_url,
      :name => name,
      :delay => 3_000,
      :service_info => :pos,
      :polling => 0
    }

    {status, _value} = HTTPoison.get("http://localhost:5000/status")

    case status do
      :err ->
        base_state = Map.put(base_state, :status, :down)

      :ok ->
        base_state = Map.put(base_state, :status, :up)
    end

    {:ok, base_state}
  end

  def handle_info(:test, state) do
    IO.puts("test")
    {:noreply, state}
  end

  def handle_cast(:start_pos_feed, state) do
    state = Map.put(state, :polling, 1)
    Process.send_after(self(), :process, 2_000)
    {:noreply, state}
  end

  def handle_cast(:stop_pos_feed, state) do
    state = Map.put(state, :polling, 0)
    {:noreply, state}
  end

  def handle_info(:process, state) do
    polling = Map.get(state, :polling)

    case polling do
      1 ->
        get_position(state)
        Process.send_after(self(), :process, 4_000)

      0 ->
        nil
    end

    {:noreply, state}
  end

  defp get_position(state) do
    pos_url = Map.get(state, :url)
    pos_url_encoded = URI.encode(pos_url)
    name = Map.get(state, :name)
    satpos=%{}
    case HTTPoison.get(pos_url_encoded) do
      {:ok, response} ->
        body = Map.get(response, :body)
        satpos = Map.put(satpos,:name,name)
        satpos = Map.put(satpos,:body,body)
      {:error, _} ->
        state = Map.replace!(state, :status, :down)
        satpos=Map.put(satpos,:name,name)
        satpos=Map.put(satpos,:body,nil)
    end
  end

  def handle_call(:info, _from, state) do
    case Map.get(state,:polling) do
        0-> 
   	    satpos = get_position(state)
     	    {:reply, satpos, state}

        1 ->
     	    {:noreply, state}
    end 
  end

  #### position status
  def handle_call(:status, _from, state) do
    status = Map.get(state, :status)
    {:reply, status, state}
  end

  def handle_call(:change_status, _from, state) do
    status = Map.get(state, :status)

    case status do
      :up ->
        state = Map.put(state, :status, :down)
        {:reply, :down, state}

      :down ->
        state = Map.put(state, :status, :up)
        IO.puts("scheduling work")
        {:reply, :up, state}

      _ ->
        {:reply, status, state}
    end
  end

  def handle_info(msg, state) do
    case msg do
      _ ->
        {:noreply, state}
    end
  end
end
