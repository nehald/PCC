defmodule CCoreWeb.UserSocket do
  use Phoenix.Socket
  require IEx
  ## Channels
  channel "user:*", CCoreWeb.UserRoomChannel
  channel "graphroom", CCoreWeb.GraphRoomChannel
  channel "topic:missileroom", CCoreWeb.MissileRoomChannel



  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.

  def connect(params, socket, connect_info) do
    #
    # Parameters: %{"current_user" => "user:nehal.desaix@aero.org", "name" => "generic", 
    # "proc_type" => "generic", "user_id" => "<0.594.0>", 
    # "user_topic" => "user:nehal.desaix@aero.org:topic", "visible" => "0", "vsn" => "2.0.0"}

    IO.puts inspect params
    user_topic  = Map.get(params,"user_topic")
    current_user  = Map.get(params,"current_user")
    case user_topic do 
    nil ->
       userid = "anonymous_"<>Integer.to_string(:rand.uniform(100000)) 
       socket = assign(socket,:current_user,userid)
       socket = assign(socket,:user_topic,userid<>":topic")
       {:ok,socket}
     _ ->
       socket = assign(socket,:user_topic,user_topic)
       socket = assign(socket,:current_user,current_user)
       {:ok, socket}
  end
 end 
  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "user_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     CCoreWeb.Endpoint.broadcast("user_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  def id(_socket), do: nil
end
