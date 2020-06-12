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
    # tx_pid = Map.get(data, :tx_pid)
    IO.puts(inspect(data))
    pos_url = "http://localhost:5000/sat/position/" <> name
    ## position server state vector 
    state = %{
      :url => pos_url,
      :name => name,
      :delay => 3_000,
      :status => :up,
      :service_info => :pos,
      :polling => 0
    }

    {:ok, state}
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
    http_call = HTTPoison.get(pos_url_encoded)

    case http_call do
      {:ok, response} ->
        body = Map.get(response, :body)
        delay = Map.get(state, :delay)
        satpos = %{:name => name, :body => body}
        state = Map.put(state, :satpos, satpos)
      {:error, _} ->
        state2 = Map.replace!(state, :status, :down)
        IO.puts("error state=" <> inspect(state2))
    end
  end

  def handle_call(:info, _from, state) do
    satpos = Map.get(state, :satpos)
    {:reply, satpos, state}
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
