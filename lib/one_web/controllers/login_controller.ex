defmodule OneWeb.LoginController do
  use OneWeb, :controller

  alias One.Authentication, as: Auth
  alias OneWeb.SessionPlug, as: Sessions
  alias Ecto.Changeset

  def index(conn, _params) do
    changeset = Auth.changeset()

    # we should email/message these to the user
    IO.inspect(changeset.changes.password, label: "your one time password")

    # TODO
    # determine why using the changeset produced by the following line
    # can't be used as the @changeset attribute in the form
    #
    # currently seeing a behavior where the deleted "password" field _is_
    # gone from the changeset, but the password field is populated in the
    # Phoenix.HTML.Form "params" field with the delete value
    #
    # passwordless_changeset = changes |> Changeset.delete_change(:password)

    # creating a new changeset is the way around this for now
    changeset = Auth.changeset(%{secret: changeset.changes.secret})

    render conn, "index.html", changeset: changeset
  end

  def create(conn, %{"authentication" => authentication}) do
    authentication
    |> Auth.changeset()
    |> Changeset.apply_changes()
    |> case do
      %Auth{} ->
        conn
        |> Sessions.login()
        |> put_flash(:info, "Welcome!")
        |> redirect(to: Routes.page_path(conn, :index))

      {:error, changeset} ->
        passwordless_changeset = changeset |> Changeset.delete_change(:password)

        conn
        |> put_flash(:error, "Password mismatch!")
        |> render("index.html", changeset: passwordless_changeset)
    end
  end

  def delete(conn, _params) do
    conn
    |> Sessions.logout()
    |> redirect(to: Routes.login_path(conn, :index))
  end
end
