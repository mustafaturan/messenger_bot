defmodule MessengerBot.Web.Plug.MaxBodyLengthTest do
  use ExUnit.Case, async: false
  alias MessengerBot.ConnHelper
  alias MessengerBot.Web.Plug.MaxBodyLength

  doctest MaxBodyLength

  @opts MaxBodyLength.init([])

  test ".call with allowed body lenth" do
    conn =
      :post
      |> ConnHelper.build_conn("/", "[]")
      |> MaxBodyLength.call(@opts)

    refute conn.halted
    refute is_nil(conn.private[:body])
  end

  test ".call with over body lenth" do
    large_body = :base64.encode(:crypto.strong_rand_bytes(128_001))
    conn =
      :post
      |> ConnHelper.build_conn("/", large_body)
      |> MaxBodyLength.call(@opts)

    expected_body = "{\"errors\":{\"body\":\"is bigger than expected\"}}"

    assert conn.halted
    assert is_nil(conn.private[:body])
    assert conn.resp_body == expected_body
  end

  test ".call bypasses when the request method is not POST" do
    conn = ConnHelper.build_conn()
    new_conn = MaxBodyLength.call(conn, @opts)

    refute new_conn.halted
    refute new_conn.method == "POST"
    assert is_nil(conn.private[:body])
    assert new_conn == conn
  end
end
