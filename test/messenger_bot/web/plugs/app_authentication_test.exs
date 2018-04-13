defmodule MessengerBot.Web.Plug.AppAuthenticationTest do
  use ExUnit.Case, async: false
  alias Plug.Conn
  alias MessengerBot.ConnHelper
  alias MessengerBot.Config
  alias MessengerBot.Web.Plug.AppAuthentication

  doctest AppAuthentication

  @opts AppAuthentication.init([])

  setup do
    conn =
      ConnHelper.build_conn()
      |> Map.put(:method, "POST")
      |> Conn.put_private(:app, Config.app("1881"))
      |> Conn.put_private(:body, "123")

    {:ok, conn: conn}
  end

  test ".call for POST request with correct signature", %{conn: conn} do
    signature = "8a895cdc3e48ce1fab4ffdcd89b557d1218bc3ba"
    signature_header_val = "sha1=" <> signature
    conn = Conn.put_req_header(conn, "x-hub-signature", signature_header_val)
    new_conn = AppAuthentication.call(conn, @opts)

    refute conn.halted
    assert new_conn == conn
  end

  test ".call for POST request with missing signature", %{conn: conn} do
    conn = AppAuthentication.call(conn, @opts)

    assert conn.halted
    assert conn.method == "POST"
    assert conn.status == 401
    assert conn.resp_body == "{\"errors\":{\"signature\":\"required\"}}"
  end

  test ".call for POST request with invalid signature", %{conn: conn} do
    signature = "invalid"
    signature_header_val = "sha1=" <> signature
    conn = Conn.put_req_header(conn, "x-hub-signature", signature_header_val)
    conn = AppAuthentication.call(conn, @opts)

    assert conn.halted
    assert conn.method == "POST"
    assert conn.status == 401
    assert conn.resp_body == "{\"errors\":{\"signature\":\"invalid\"}}"
  end

  test ".call bypasses when the request method is not POST", %{conn: conn} do
    conn = Map.put(conn, :method, "GET")
    new_conn = AppAuthentication.call(conn, @opts)

    refute new_conn.halted
    refute new_conn.method == "POST"
    assert new_conn == conn
  end
end
