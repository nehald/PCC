defmodule CCoreWeb.TestController do
  require IEx
  use CCoreWeb, :controller

   def action(conn, _opts) do
    IEx.pry
    args = [conn, conn.params, conn.assigns.current_user] 
   end


  def test(conn, params) do
    IEx.pry 
    name = Map.get(params, "name")
   end 

end 
