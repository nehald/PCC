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
    "graphdb:" <> user_id
  end

  defp get_user_topic_id(user_id) do
    "topic:" <> user_id
  end

  ## sat configs 
  ## 1. sat name (required)
  ## 2. owner/userid (derived from cookid data)
  ## 3. type (required)
  ## 4. channel (optional) 
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
#      |> Swarm.whereis_name()

    sat_name = Map.get(params, "name")
    params = Map.put(params, :current_user, current_user)
    params = Map.put(params, :user_id, user_id)
    params = Map.put(params, :user_topic, user_topic_id)
   
    #> params  
    #%{      
    #	:current_user => "user:nehal.desaix@aero.org",
    # 	:user_id => #PID<0.564.0>,
    #	:user_topic => "topic:user:nehal.desaix@aero.org",
    #	"extra_channels" => ["topic:missileroom"],
    #	"name" => "GOES 15",
    #	"visible" => 0
    #}
    

    {:ok, satpid} = Sat.start_link(params)
    # Swarm.register_name(name, satpid)
    return_dict = %{"cmd" => "spawn", "name" => sat_name}
    json(conn, return_dict)
  end

  def get_graph(conn, params) do
    current_user_id = get_session(conn, :current_user_id)
    ## lookup graphdb
    ## 1.  find user process 
    user_account_pid = Swarm.whereis_name(current_user_id)
    {:ok, graphdb} = GenServer.cast(user_account_pid, :get_graph)
  end

  def swarm_info(conn, params) do
    key = Map.get(params, "key")
    val = Map.get(params, "val")

    case key do
      "registered" ->
        retval = Swarm.registered()
        IEx.pry()
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
        IO.puts("val" <> inspect(msg))
        json(conn, msg)
    end
  end

  def missile_traj(conn, params) do
    missile_name = Map.get(params, "missile_name")
    cmd = Map.get(params, "cmd")

    case cmd do
      "launch" ->
        {:ok, missile_pid} = MissileLauncher.start_link(missile_name)
        IEx.pry()
        Swarm.register_name(missile_name, missile_pid)
        return_dict = %{"cmd" => "launched", "name" => missile_name}
        json(conn, return_dict)

      "add_position" ->
        missile_pid = Swarm.whereis_name(missile_name)
        position = Map.get(params, "position")
        GenServer.cast(missile_pid, {:add_position, position})
        return_dict = %{"cmd" => "adding_position", "pos" => position}
        json(conn, return_dict)

      _ ->
        nil
    end
  end
end
