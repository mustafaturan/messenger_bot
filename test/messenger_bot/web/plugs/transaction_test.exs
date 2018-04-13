defmodule MessengerBot.Web.Plug.TransactionTest do
  use ExUnit.Case, async: false
  alias MessengerBot.ConnHelper
  alias MessengerBot.Web.Plug.Transaction

  doctest Transaction

  @opts Transaction.init([])

  test ".call" do
    conn = ConnHelper.build_conn()
    conn = Transaction.call(conn, @opts)

    refute conn.halted
    refute is_nil(conn.private[:tx_id])
  end
end
