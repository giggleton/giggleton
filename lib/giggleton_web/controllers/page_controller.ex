defmodule GiggletonWeb.PageController do
  use GiggletonWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
