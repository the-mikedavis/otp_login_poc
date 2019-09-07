defmodule OneWeb.SessionPlug do
  import Plug.Conn
  import Phoenix.Controller
  alias OneWeb.Router.Helpers, as: Routes

  def init(opts), do: opts

  def call(conn, _opts) do
    conn = fetch_user(conn)

    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> put_flash(:error, "you must be signed in to view that page")
      |> redirect(to: Routes.login_path(conn, :index))
      |> halt()
    end
  end

  def fetch_user(conn) do
    user = get_session(conn, :user)
    assign(conn, :current_user, user)
  end

  @hard_coded_user_id "1"

  def login(conn) do
    conn
    |> assign(:current_user, @hard_coded_user_id)
    |> put_session(:user, @hard_coded_user_id)
    |> configure_session(renew: true)
  end

  def logout(conn) do
    conn
    |> configure_session(drop: true)
  end
end
