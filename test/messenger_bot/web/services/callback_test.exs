defmodule MessengerBot.Web.Service.CallbackTest do
  use ExUnit.Case, async: false
  alias MessengerBot.Web.Service.Callback
  alias MessengerBot.PayloadFixtures
  alias EventBus.Manager.Notification

  doctest Callback

  @app_id "1881"
  @page_id "1234"
  @account_linking_payload PayloadFixtures.load("account_linking")
  @attachments_payload PayloadFixtures.load("attachments")
  @checkout_update_payload PayloadFixtures.load("checkout_update")
  @delivery_payload PayloadFixtures.load("delivery")
  @echo_payload PayloadFixtures.load("echo")
  @game_play_payload PayloadFixtures.load("game_play")
  @handovers_payload PayloadFixtures.load("handovers")
  @message_payload PayloadFixtures.load("message")
  @optin_payload PayloadFixtures.load("optin")
  @payment_payload PayloadFixtures.load("payment")
  @policy_enforcement_payload PayloadFixtures.load("policy_enforcement")
  @postback_payload PayloadFixtures.load("postback")
  @pre_checkout_payload PayloadFixtures.load("pre_checkout")
  @quick_reply_payload PayloadFixtures.load("quick_reply")
  @read_payload PayloadFixtures.load("read")
  @referral_payload PayloadFixtures.load("referral")
  @standby_payload PayloadFixtures.load("standby")
  @unkown_payload PayloadFixtures.load("unknown")

  test ".run for account_linking event" do
    assert_notify @account_linking_payload, :mb_account_linking_received
  end

  test ".run for attachments event" do
    assert_notify @attachments_payload, :mb_message_attachments_received
  end

  test ".run for checkout_update event" do
    assert_notify @checkout_update_payload, :mb_checkout_update_received
  end

  test ".run for delivery event" do
    assert_notify @delivery_payload, :mb_delivery_received
  end

  test ".run for echo event" do
    assert_notify @echo_payload, :mb_message_echo_received
  end

  test ".run for game_play event" do
    assert_notify @game_play_payload, :mb_game_play_received
  end

  test ".run for message event" do
    assert_notify @message_payload, :mb_message_received
  end

  test ".run for optin event" do
    assert_notify @optin_payload, :mb_optin_received
  end

  test ".run for payment event" do
    assert_notify @payment_payload, :mb_payment_received
  end

  test ".run for policy_enforcement event" do
    assert_notify @policy_enforcement_payload, :mb_policy_enforcement_received
  end

  test ".run for postback event" do
    assert_notify @postback_payload, :mb_postback_received
  end

  test ".run for pre_checkout event" do
    assert_notify @pre_checkout_payload, :mb_pre_checkout_received
  end

  test ".run for quick_reply event" do
    assert_notify @quick_reply_payload, :mb_message_quick_reply_received
  end

  test ".run for read event" do
    assert_notify @read_payload, :mb_read_received
  end

  test ".run for referral event" do
    assert_notify @referral_payload, :mb_referral_received
  end

  test ".run for unknown event" do
    assert_notify @unkown_payload, :mb_na_received
  end

  test ".run for handovers#* event" do
    event_notifier_pid = Process.whereis Notification
    :erlang.trace(event_notifier_pid, true, [:receive])

    assert Callback.run(@app_id, @handovers_payload, unique_id()) == :ok

    Process.sleep(10)

    for _ <- 0..3 do
      assert_received {:trace, ^event_notifier_pid, :receive,
        {:"$gen_cast", {:notify, _}}}
    end
  end

  test ".run for standby event" do
    event_notifier_pid = Process.whereis Notification
    :erlang.trace(event_notifier_pid, true, [:receive])

    assert Callback.run(@app_id, @standby_payload, unique_id()) == :ok

    Process.sleep(10)
    assert_received {:trace, ^event_notifier_pid, :receive,
      {:"$gen_cast", {:notify, event}}}

    assert event.topic == :mb_standby_received
    assert event.data.app_id == @app_id
    assert event.data.page_id == @page_id
    refute is_nil(event.data.standby)
    refute is_nil(event.data.time)
  end

  defp assert_notify(payload, expected_topic) do
    event_notifier_pid = Process.whereis Notification
    :erlang.trace(event_notifier_pid, true, [:receive])

    assert Callback.run(@app_id, payload, unique_id()) == :ok

    Process.sleep(10)
    assert_received {:trace, ^event_notifier_pid, :receive,
      {:"$gen_cast", {:notify, event}}}

    assert event.topic == expected_topic
    assert event.data.app_id == @app_id
    assert event.data.page_id == @page_id
    refute is_nil(event.data.messaging)
    refute is_nil(event.data.time)
  end

  defp unique_id do
    UUID.uuid4()
  end
end
