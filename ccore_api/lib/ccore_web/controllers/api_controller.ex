defmodule CCoreWeb.ApiController do
  require IEx
  import Sat
  use CCoreWeb, :controller
  alias CCore.Auth
  alias CCore.Auth.User

  defp get_user_id(current_user_id) do
    email = Auth.get_user!(current_user_id).email
    "user:" <> email
  end

  defp get_user_graph_id(user_id) do
    user_id <> ":graphdb"
  end

  defp get_user_topic_id(user_id) do
    user_id <> ":topic"
  end

  @doc """
   Spawns the node  

  """
  def spawn(conn, params) do
    ## get the userid  
    current_user =
      conn
      |> get_session(:current_user_id)
      |> get_user_id

    ## get userpid,graphid,topicid 
    user_id =
      current_user
      |> Swarm.whereis_name()

    user_graph_id =
      current_user
      |> get_user_graph_id
      |> Swarm.whereis_name()

    user_topic_id =
      current_user
      |> get_user_topic_id

    params = Map.put(params, :current_user, current_user)
    params = Map.put(params, :user_id, user_id)
    params = Map.put(params, :user_graph_id, user_graph_id)
    params = Map.put(params, :user_topic, user_topic_id)

    ## info that cames in from the curl 
    type = Map.get(params, "proc_type")
    proc_name = current_user <> ":proc:" <> Map.get(params, "name")
    # > params  
    # %{      
    # 	:current_user => "user:nehal.desaix@aero.org",
    # 	:user_id => #PID<0.564.0>,
    # 	:user_topic => "user:nehal.desaix@aero.org:topic",
    # 	"extra_channels" => ["topic:missileroom"],
    # 	"name" => "GOES 15",
    # 	"visible" => 0
    # }
    case type do
      "sat" ->
        {:ok, pid} = Sat.start_link(params)
        Swarm.register_name(proc_name, pid)
        return_dict = %{"cmd" => "spawn", "name" => proc_name}
        json(conn, return_dict)

      "generic" ->
        {:ok, pid} = Generic.start_link(params)
        GenServer.cast(user_graph_id, {:add_edge, current_user, proc_name})
        Swarm.register_name(proc_name, pid)
        return_dict = %{"cmd" => "spawn", "name" => proc_name}
        json(conn, return_dict)

      "groundstation" ->
        {:ok, pid} = Groundstation.start_link(params)
        Swarm.register_name(proc_name, pid)
        return_dict = %{"cmd" => "spawn", "name" => proc_name}
        json(conn, return_dict)

      _ ->
        return_dict = %{"cmd" => type, "name" => proc_name}
        json(conn, return_dict)
    end

    # Swarm.register_name(name, satpid)
  end

  def gs_connect(conn, params) do
    current_user =
      conn
      |> get_session(:current_user_id)
      |> get_user_id

    gs_proc_name = Map.get(params, "gs")

    groundstation_pid =
      gs_proc_name
      |> Swarm.whereis_name()

    sat_proc_name = Map.get(params, "sat")

    sat_pid =
      sat_proc_name
      |> Swarm.whereis_name()

    state = GenServer.call(groundstation_pid, {:add_connection, sat_pid})
    return_dict = %{"cmd" => "gs_to_sat", "gs" => gs_proc_name, "sat" => sat_proc_name}
    json(conn, return_dict)
  end

  @doc """
    Get connection info from a groundstation 
  """
  def gs_info(conn, params) do
    current_user =
      conn
      |> get_session(:current_user_id)
      |> get_user_id

    gs_proc_name = Map.get(params, "gs")

    groundstation_pid =
      gs_proc_name
      |> Swarm.whereis_name()

    m = GenServer.call(groundstation_pid, {:info, "connection_info"})
    return_dict = %{"cmd" => "gs_info", "gs" => gs_proc_name, "sat" => m}

    json(conn, return_dict)
  end

  @doc """
   Get info about the sats connected to this groundstation
  """
  def gs_sat_info(conn, params) do
    current_user =
      conn
      |> get_session(:current_user_id)
      |> get_user_id

    gs_proc_name = Map.get(params, "gs")

    groundstation_pid =
      gs_proc_name
      |> Swarm.whereis_name()

    m = GenServer.call(groundstation_pid, {:info, "sat_info"})
    json(conn, m)
  end

  @doc """
   Get info about a sat directly
   generic(:sat_info) -> satprop(:info) 

  """
  def sat_info(conn, params) do
    current_user =
      conn
      |> get_session(:current_user_id)
      |> get_user_id

    sat_name = Map.get(params, "sat_handle")
    sat_pid = sat_name |> Swarm.whereis_name()
    info = GenServer.call(sat_pid, {:sat_info, params})
    json(conn, info)
  end

  def sat_group(conn, params) do
    group_name = Map.get(params, "group_name")
    sat_name = Map.get(params, "sat_handle")
    sat_pid = sat_name |> Swarm.whereis_name()
    Swarm.join(group_name, sat_pid)
    return_dict = %{"cmd" => "join_group", "sat" => sat_name, "group" => group_name}
    json(conn, return_dict)
  end

  ####
  def sat_group_call(conn, params) do
    group_name = Map.get(params, "group_name")
    info = Swarm.multi_call(group_name, {:sat_info, params})
    return_dict = %{"cmd" => "sat_group_call", "val" => info}
    json(conn, info)
  end

  def graph(conn, params) do
    current_user =
      conn
      |> get_session(:current_user_id)
      |> get_user_id

    user_graph_pid =
      current_user
      |> get_user_graph_id
      |> Swarm.whereis_name()

    dotfile = GenServer.call(user_graph_pid, {:graph_info, []})
    return_dict = %{"dotfile" => dotfile}
    json(conn, return_dict)
  end


  #### start the channel
  def topic_create(conn, params) do
    current_user =
      conn
      |> get_session(:current_user_id)
      |> get_user_id

    topic = Map.get(params, "topic")
    topic_name = current_user<>":topic:"<>topic
    params = %{:current_user => current_user, :user_topic => topic_name}

    socket_opts = [
      url: "ws://localhost:4000/socket/websocket",
      params: params
    ]

    {:ok, socket} = PhoenixClient.Socket.start_link(socket_opts)
    :timer.sleep(1000)
    {:ok, response, channel} = PhoenixClient.Channel.join(socket, topic_name)
    topic_name = current_user<>":topic:"<>topic
    Swarm.register_name(topic_name,channel) 
    return_dict =%{"topic"=>topic_name}   
    json(conn, return_dict)
  end

  def swarm_info(conn, params) do
    key = Map.get(params, "key")
    val = Map.get(params, "val")

    case key do
      "registered" ->
        retval = Swarm.registered()
        json(conn, retval)

      "whereis" ->
        retval = Swarm.whereis_name(val)
        json(conn, retval)

      "members" ->
        retval = Swarm.members(val)
        json(conn, retval)
    end
  end

  def status(conn, params) do
    sat_name = Map.get(params, "name")
    system = Map.get(params, "system")
    action = Map.get(params, "action")
    ## lookup name in sat process db
    sat_pid = Swarm.whereis_name(sat_name)

    case sat_pid do
      nil ->
        msg_str = "No sat name" <> sat_name
        msg = %{:msg => msg_str}
        json(conn, msg)

      _ ->
        {:ok, val} = GenServer.call(sat_pid, {:status, system})
        msg = %{"name" => sat_name, "system" => system, "status" => val}
        json(conn, msg)
    end
  end
end
