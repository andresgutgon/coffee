defmodule AppWeb.HomeController do
  use AppWeb, :controller

  def index(conn, _params) do
    ssr = true
    conn
    |> assign_prop(:first_name, "Bob")
    |> assign_prop(:ssr, ssr)
    |> render_inertia("HomePage", ssr: ssr)
  end
end
