defmodule MessengerBot.Web.Controller.MessengerTest do
  use ExUnit.Case, async: false

  import Mock

  alias MessengerBot.Config
  alias MessengerBot.ConnHelper
  alias MessengerBot.Web.Controller.Messenger, as: MessengerController
  alias MessengerBot.Web.Service.{Callback, Setup}
  alias Plug.Conn

  doctest MessengerController

  @app_id "1881"
  @app Config.app(@app_id)

  test ".setup" do
    conn =
      :get
      |> ConnHelper.build_conn("/#{@app_id}?a=1&b=2&c=3")
      |> Conn.put_private(:app, @app)

    with_mock Setup, [run: fn(_, _) -> {:ok, %{"hub.challenge" => "icebucket"}} end] do
      conn = MessengerController.setup(conn)

      assert called Setup.run(@app, %{"a" => "1", "b" => "2", "c" => "3"})
      assert conn.state == :sent
      assert conn.status == 200
      assert conn.resp_body == "icebucket"
    end
  end

  test ".callback" do
    conn =
      :post
      |> ConnHelper.build_conn("/#{@app_id}")
      |> Conn.put_private(:app, @app)
      |> Conn.put_private(:tx_id, "123")
      |> Conn.put_private(:body, "{\"entry\":[]}")

    with_mock Callback, [run: fn(_, _, _) -> :ok end] do
      conn = MessengerController.callback(conn)

      assert conn.state == :sent
      assert conn.status == 200
      assert conn.resp_body == "[]"
    end
  end
end
