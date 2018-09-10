defmodule MessengerBot.Web.Plug.EventBusTest do
  use ExUnit.Case, async: false

  alias EventBus.Manager.Notification
  alias MessengerBot.Config
  alias MessengerBot.ConnHelper
  alias MessengerBot.Web.Plug.EventBus, as: EventBusPlug

  doctest EventBusPlug

  defmodule MySampleRoute do
    use Plug.Builder
    alias Plug.Conn

    plug EventBusPlug, topic_prefix: :mb_test
    plug :passthrough

    defp passthrough(conn, _) do
      Conn.send_resp(conn, 200, "ok")
    end
  end

  test ".call" do
    conn = ConnHelper.build_conn(:get, "/")
    assert_notify conn, :mb_test_succeeded
  end

  defp assert_notify(conn, expected_topic) do
    event_notifier_pid = Process.whereis Notification
    :erlang.trace(event_notifier_pid, true, [:receive])

    MySampleRoute.call(conn, [])

    Process.sleep(10)
    assert_received {:trace, ^event_notifier_pid, :receive,
      {:"$gen_cast", {:notify, event}}}

    assert event.topic == expected_topic
    assert event.ttl == Config.eb_ttl()
    assert event.source == "Plug.EventBus"
    assert is_nil(event.transaction_id)
    assert is_nil(event.data.app_id)
    refute is_nil(event.data.request)
    refute is_nil(event.data.response)
  end
end
