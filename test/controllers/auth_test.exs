defmodule Rumbl.AuthTest do
  use Rumbl.ConnCase
  alias Rumbl.Auth
  
  setup %{conn: conn} do
    conn =
      conn
      |> bypass_through(Rumbl.Router, :browser)
      |> get("/")
      
      {:ok, %{conn: conn}}
  end
  
  test "user can login with valid username and password", %{conn: conn} do
    user = insert_user(username: "me", password: "secret")
    {:ok, conn} = Auth.login_by_username_and_pass(conn, "me", "secret", repo: Repo)
    
    assert conn.assigns.current_user.id == user.id
  end
  
  test "login with password mismatch", %{conn: conn} do
    _ = insert_user(username: "me", password: "secret")
    
    assert {:error, :unauthorized, _conn} =
      Auth.login_by_username_and_pass(conn, "me", "wrongpassword", repo: Repo) 
  end
  
  test "call places user from session into assigns", %{conn: conn} do
    user = insert_user()
    conn =
      conn
      |> put_session(:user_id, user.id)
      |> Auth.call(Repo)
    
    assert conn.assigns.current_user.id == user.id
  end
  
  test "call with no session sets current_user assign to nil", %{conn: conn} do
    conn = Auth.call(conn, Repo)
    assert conn.assigns.current_user == nil 
  end
  
  test "logout drops session", %{conn: conn} do
    logout_conn =
      conn
      |> put_session(:user_id, 123)
      |> Auth.logout()
      |> send_resp(:ok, "")
      
    next_conn = get(logout_conn, "/")
    refute get_session(next_conn, :user_id) 
  end
  
  test "login puts the user in the session", %{conn: conn} do
    login_conn =
      conn
      |> Auth.login(%Rumbl.User{id: 123})
      |> send_resp(:ok, "")
      
    next_conn = get(login_conn, "/")
    assert get_session(next_conn, :user_id) == 123
  end
  
  test "authenticate_user halts when no current_user exists", %{conn: conn} do
    conn = 
      conn
      |> assign(:current_user, nil)
      |> Auth.authenticate_user([])

    assert conn.halted 
  end
  
  test "authenticate_user continues when current_user exists", %{conn: conn} do
    conn = 
      conn
      |> assign(:current_user, %Rumbl.User{})
      |> Auth.authenticate_user([])
      
      refute conn.halted 
  end
end