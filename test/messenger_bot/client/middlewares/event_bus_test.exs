defmodule MessengerBot.Client.Middleware.EventBusTest do
  use ExUnit.Case, async: false
  alias MessengerBot.Config
  alias EventBus.Manager.Notification

  @app_id "1881"
  @page_id "1234"
  @topic :mb_test
  @opts [
          app_id: @app_id,
          page_id: @page_id,
          eb_tx_id: UUID.uuid4(),
          eb_topic: @topic
        ]

  defmodule Client do
    use Tesla

    plug MessengerBot.Client.Middleware.EventBus

    adapter fn env ->
      case env.url do
        "/" -> {:ok, %{status: 200, body: "{\"id\": 123456}"}}
        "/404" -> {:ok, %{status: 404, body: "{\"status\": \"not found\"}"}}
        "/na" -> {:error, :econnrefused}
      end
    end
  end

  describe "EventBus" do
    test "notify `_succeeded` topic when HTTP call succeeded with 200 status" do
      assert_notify "/", :mb_test_succeeded
    end

    test "notify `_failed` topic when HTTP call failed with non 200 status" do
      assert_notify "/404", :mb_test_failed
    end

    test "notify `_erred` topic when HTTP client error" do
      assert_notify "/na", :mb_test_erred
    end
  end

  defp assert_notify(path, expected_topic) do
    event_notifier_pid = Process.whereis Notification
    :erlang.trace(event_notifier_pid, true, [:receive])

    Client.get(path, opts: @opts)

    Process.sleep(10)
    assert_received {:trace, ^event_notifier_pid, :receive,
      {:"$gen_cast", {:notify, event}}}

    assert event.topic == expected_topic
    assert event.ttl == Config.eb_ttl()
    assert event.source == "MessengerBot.Client"
    assert event.data.app_id == @app_id
    assert event.data.page_id == @page_id
    refute is_nil(event.data.request)
    refute is_nil(event.data.response)
  end
end
