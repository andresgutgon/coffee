defmodule AppWeb.PageController do
  use AppWeb, :controller

  def index(conn, _params) do
  end

  def inertia(conn, _params) do
    conn
    |> render_inertia("Dashboard")
  end
end
