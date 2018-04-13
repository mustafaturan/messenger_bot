defmodule MessengerBot.Web.RouterTest do
  use ExUnit.Case, async: true
  use Plug.Test
  import Mock
  alias MessengerBot.Web.{Router, Renderer}
  alias MessengerBot.Web.Controller.Messenger

  @app_id "1881"

  test "returns *non* 404 when `GET` req for existing app route" do
    response = Router.call(conn(:get, "/#{@app_id}"), [])

    refute response.status == 404
  end

  test "returns 404 when `GET` req for non-existing app route" do
    response = Router.call(conn(:get, "/1234"), [])

    assert response.status == 404
  end

  test "returns 200 when `POST` req for existing app route with right header" do
    body = "[]"
    signature = "2399c8b5bd4513ed60c5724c0e8167325bab19a9"
    conn =
      :post
      |> conn("/#{@app_id}", body)
      |> put_req_header("x-hub-signature", "sha1=" <> signature)

    with_mock Messenger, [callback: fn(_) -> Renderer.send_ok(conn) end] do
      response = Router.call(conn, [])
      assert response.status == 200
    end
  end

  test "returns *non* 404 when `POST` req for existing app route" do
    response = Router.call(conn(:post, "/#{@app_id}"), [])

    refute response.status == 404
  end

  test "returns 404 when `POST` req for non-existing app route" do
    response = Router.call(conn(:post, "/1234"), [])

    assert response.status == 404
  end

  test "returns 404(not found) for all other routes" do
    response1 = Router.call(conn(:put, "/#{@app_id}"), [])
    response2 = Router.call(conn(:delete, "/#{@app_id}"), [])
    response3 = Router.call(conn(:options, "/#{@app_id}"), [])
    response4 = Router.call(conn(:head, "/#{@app_id}"), [])

    assert response1.status == 404
    assert response2.status == 404
    assert response3.status == 404
    assert response4.status == 404
  end
end
