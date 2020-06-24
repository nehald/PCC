defmodule Battery do
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
  

  end
end
