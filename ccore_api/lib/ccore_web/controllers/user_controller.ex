defmodule CCoreWeb.UserController do
  use CCoreWeb, :controller
  require IEx
  alias CCore.Auth
  alias CCore.Auth.User

  action_fallback(CCoreWeb.FallbackController)

  def index(conn, _params) do
    users = Auth.list_users()
    render(conn, "index.json", users: users)
  end

  def create(conn, %{"user" => user_params}) do
    case Auth.create_user(user_params) do
      {:ok, user} ->
        ## extract userid 
        userid = user.id
        CCore.User.start_link(user)
        ## 
        conn
        |> put_status(:created)
        |> put_resp_header("location", Routes.user_path(conn, :show, user))
        |> render("show.json", user: user)

      {:error, message} ->
        msg = %{"error" => "hello"}

        conn
        |> put_status(:im_used)
        |> put_view(CCoreWeb.ErrorView)
        |> render("401.json", message: msg)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Auth.get_user!(id)
    render(conn, "show.json", user: user)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Auth.get_user!(id)

    with {:ok, %User{} = user} <- Auth.update_user(user, user_params) do
      render(conn, "show.json", user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Auth.get_user!(id)

    with {:ok, %User{}} <- Auth.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end

  defp restart_code?(email) do
    swarm_reg_name = "user:"<>email
    case Swarm.whereis_name(swarm_reg_name) do
      :undefined ->
        IO.puts("restarting user")
        args = %{:email => email}
        CCore.User.start_link(args)
        :timer.sleep(1000)
        {:ok, :restarted}

      _ ->
        {:ok, :already_started}
    end
  end

  @doc """
  Adding code to support authentication
  """
  def sign_in(conn, %{"email" => email, "password" => password}) do
    ## 
    registry_name = "user:" <> email
    case Auth.authenticate_user(email, password) do
      {:ok, user} ->
        {ok, msg} = restart_code?(email)
        ## render view  
        conn
        |> put_session(:current_user_id, user.id)
        |> put_status(:ok)
        |> put_view(CCoreWeb.UserView)
        |> render("sign_in.json", user: user)

      {:error, message} ->
        IEx.pry()
        conn
        |> delete(:current_user_id)
        |> put_status(:unauthorized)
        |> put_view(CCoreWeb.ErrorView)
        |> render("401.json", message: message)
    end
  end

  ## mod end
end
