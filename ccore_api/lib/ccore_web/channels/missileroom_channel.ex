defmodule CCoreWeb.MissileRoomChannel do
  use CCoreWeb, :channel
  alias CCoreWeb.Presence
  require IEx

  def join("topic:missileroom", payload, socket) do
    send(self(), :after_join)
    {:ok, socket}
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (room:lobby).
  def handle_in("push", payload, socket) do
    broadcast!(socket, "shout", payload)
    {:noreply, socket}
  end

  def handle_info(:after_join, socket) do
    IO.puts inspect(socket)
    {:ok, _} =
      Presence.track(socket, socket.assigns.userid, %{
        online_at: inspect(System.system_time(:second))
      })
    push(socket, "presence_state", Presence.list(socket))
   {:noreply, socket}
  end

  def handle_info(msg,socket) do
     IO.puts inspect socket 
     {:noreply,socket}
  end 

 
  def handle_in(msg, _payload, socket) do
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
