defmodule MessengerBot.Web.Service.Callback do
  @moduledoc """
  MessengerBot webhook callback handler
  """

  use EventBus.EventSource

  alias EventBus.Util.MonotonicTime
  alias MessengerBot.Util.JSON
  alias MessengerBot.Util.String, as: MessengerBotStringUtil

  @doc """
  Process messaging webhooks coming from Facebook Messenger Platform
  """
  @spec run(String.t(), String.t(), String.t()) :: :ok
  def run(app_id, payload, transaction_id) do
    {:ok, payload} = JSON.decode(payload)

    Enum.each(payload["entry"], fn entry ->
      process_entry(transaction_id, {app_id, entry})
    end)

    :ok
  end

  @spec process_entry(String.t(), tuple()) :: :ok
  defp process_entry(transaction_id, {app_id, %{"messaging" => messagings, "time" => time, "id" => page_id}}) do
    Enum.each(messagings, fn messaging ->
      process_messaging(transaction_id, {app_id, page_id, time, messaging})
    end)

    :ok
  end

  defp process_entry(transaction_id, {app_id, %{"standby" => standby, "time" => time, "id" => page_id}}) do
    params =
      :mb_standby_received
      |> init_event_params(transaction_id)
      |> Map.put(:initialized_at, MonotonicTime.now())
      |> Map.put(:data, %{app_id: app_id, standby: standby, page_id: page_id, time: time})
      |> Map.put(:occurred_at, MonotonicTime.now())
      |> Map.put(:id, MessengerBotStringUtil.unique_id())

    EventBus.notify(struct(Event, params))
  end

  @spec process_messaging(String.t(), tuple()) :: :ok
  defp process_messaging(transaction_id, {app_id, page_id, time, messaging}) do
    params =
      messaging
      |> fetch_topic()
      |> init_event_params(transaction_id)
      |> Map.put(:initialized_at, MonotonicTime.now())
      |> Map.put(:data, %{app_id: app_id, messaging: messaging, page_id: page_id, time: time})
      |> Map.put(:occurred_at, MonotonicTime.now())
      |> Map.put(:id, MessengerBotStringUtil.unique_id())

    EventBus.notify(struct(Event, params))
  end

  defp fetch_topic(%{"delivery" => _}) do
    :mb_delivery_received
  end

  defp fetch_topic(%{"read" => _}) do
    :mb_read_received
  end

  defp fetch_topic(%{"message" => %{"is_echo" => true}}) do
    :mb_message_echo_received
  end

  defp fetch_topic(%{"message" => %{"attachments" => _}}) do
    :mb_message_attachments_received
  end

  defp fetch_topic(%{"message" => %{"quick_reply" => _}}) do
    :mb_message_quick_reply_received
  end

  defp fetch_topic(%{"message" => _}) do
    :mb_message_received
  end

  defp fetch_topic(%{"postback" => _}) do
    :mb_postback_received
  end

  defp fetch_topic(%{"optin" => _}) do
    :mb_optin_received
  end

  defp fetch_topic(%{"referral" => _}) do
    :mb_referral_received
  end

  defp fetch_topic(%{"game_play" => _}) do
    :mb_game_play_received
  end

  defp fetch_topic(%{"payment" => _}) do
    :mb_payment_received
  end

  defp fetch_topic(%{"checkout_update" => _}) do
    :mb_checkout_update_received
  end

  defp fetch_topic(%{"pre_checkout" => _}) do
    :mb_pre_checkout_received
  end

  defp fetch_topic(%{"account_linking" => _}) do
    :mb_account_linking_received
  end

  defp fetch_topic(%{"policy_enforcement" => _}) do
    :mb_policy_enforcement_received
  end

  defp fetch_topic(%{"policy-enforcement" => _}) do
    :mb_policy_enforcement_received
  end

  defp fetch_topic(%{"app_roles" => _}) do
    :mb_app_roles_received
  end

  defp fetch_topic(%{"pass_thread_control" => _}) do
    :mb_pass_thread_control_received
  end

  defp fetch_topic(%{"take_thread_control" => _}) do
    :mb_take_thread_control_received
  end

  defp fetch_topic(%{"request_thread_control" => _}) do
    :mb_request_thread_control_received
  end

  defp fetch_topic(_) do
    :mb_na_received
  end

  defp init_event_params(topic, transaction_id) do
    %{
      topic: topic,
      transaction_id: transaction_id
    }
  end
end
