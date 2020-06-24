defmodule CCoreWeb.Router do
  use CCoreWeb, :router
  require IEx
 pipeline :api_auth do
    plug :ensure_authenticated
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
  end

  scope "/api", CCoreWeb do
    pipe_through [:api, :api_auth] 
    resources "/users", UserController, except: [:create,:new, :edit]
    post "/spawn",ApiController,:spawn
    post "/graph",ApiController,:get_graph 
    post "/gs/connect",ApiController,:gs_connect
    post "/gs/info",ApiController,:gs_info
    post "/gs/info/sat",ApiController,:gs_sat_info
    post "/sat/info",ApiController,:sat_info
    post "/sat/group",ApiController,:sat_group
    post "/sat/group_call",ApiController,:sat_group_call
    post "/channel/create",ApiController,:topic_create
    post "/channel/push",ApiController,:topic_push
    post "/swarm/info",ApiController,:swarm_info
  end
 
  scope "/api", CCoreWeb do 
    pipe_through :api
    post "/users/sign_in", UserController, :sign_in
    post "/users/create", UserController, :create
  end

  defp ensure_authenticated(conn, _opts) do
    current_user_id = get_session(conn, :current_user_id)
    if current_user_id do
      conn
    else
      conn
      |> put_status(:unauthorized)
      |> put_view(CCoreWeb.ErrorView)
      |> render("401.json", message: "Unauthenticated user")
      |> halt()
    end
  end
end
