defmodule CCoreWeb.GraphRoomChannel do
  use CCoreWeb, :channel
  require IEx
  def join("graphroom", payload, socket) do
      {:ok, socket}
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (room:lobby).
  def handle_in("bcast_graph", payload, socket) do
    broadcast! socket, "push", payload
    {:noreply, socket}
  end

 def handle_in(msg,payload,socket) do
    IEx.pry
    IO.puts msg
    {:noreply,socket}
 end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
