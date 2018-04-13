defmodule MessengerBot.Web.Plug.AppIdentificationTest do
  use ExUnit.Case, async: false
  alias MessengerBot.ConnHelper
  alias MessengerBot.Web.Plug.AppIdentification

  doctest AppIdentification

  @opts AppIdentification.init([])

  test ".call with an existent app id" do
    conn = ConnHelper.build_conn(:get, "/webhooks/1881")
    conn = AppIdentification.call(conn, @opts)

    refute conn.halted
    refute is_nil(conn.private[:app])
  end

  test ".call with non existent app id" do
    conn = ConnHelper.build_conn(:get, "/webhooks/1234")
    conn = AppIdentification.call(conn, @opts)

    assert conn.halted
    assert conn.resp_body == "{\"errors\":{\"app\":\"not found\"}}"
    assert is_nil(conn.private[:app])
  end
end
