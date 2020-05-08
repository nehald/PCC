defmodule CCoreWeb.PythonServer do
  use GenServer
  alias CCoreWeb.Python

  def start_link() do
    GenServer.start_link(__MODULE__, [])
  end

  def init(args) do
    # start the python session and keep pid in state
    python_session = Python.start()
    # register this process as the message handler
    Python.call(python_session, :test, :register_handler, [self()])
    {:ok, python_session}
  end


  def cast_replay(csvfile) do
    {:ok, pid} = start_link()
    GenServer.cast(pid, {:replay, csvfile})
  end

  def handle_cast({:replay, csvfile}, session) do
     Python.cast(session, csvfile)
    {:noreply, session}
  end

  def handle_info({:python, message}, session) do
    IO.puts("Received message from python: #{inspect(message)}")
    IO.puts("*************************")  
    {:noreply,session}
  end

  def terminate(_reason, session) do
    Python.stop(session)
    :ok
  end
end
