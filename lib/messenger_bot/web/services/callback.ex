defmodule MessengerBot.Web.Service.Callback do
  @moduledoc """
  MessengerBot webhook callback handler
  """

  use EventBus.EventSource
  alias MessengerBot.Config
  alias MessengerBot.Util.JSON

  @doc """
  Process messaging webhooks coming from Facebook Messenger Platform
  """
  @spec run(integer(), String.t(), String.t()) :: :ok
  def run(app_id, payload, transaction_id) do
    {:ok, payload} = JSON.decode(payload)

    for entry <- payload["entry"] do
      process_entry(transaction_id, {app_id, entry})
    end

    :ok
  end

  defp process_entry(transaction_id, {app_id, %{"messaging" => messagings, "time" => time, "id" => page_id}}) do
    for messaging <- messagings do
      process_messaging(transaction_id, {app_id, page_id, time, messaging})
    end
  end

  defp process_entry(transaction_id, {app_id, %{"standby" => standby, "time" => time, "id" => page_id}}) do
    params = init_event_params(:mb_standby_received, transaction_id)

    EventSource.notify params do
      %{app_id: app_id, standby: standby, page_id: page_id, time: time}
    end
  end

  defp process_messaging(transaction_id, {app_id, page_id, time, messaging}) do
    params = init_event_params(fetch_topic(messaging), transaction_id)

    EventSource.notify params do
      %{app_id: app_id, messaging: messaging, page_id: page_id, time: time}
    end
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
      id: unique_id(),
      topic: topic,
      transaction_id: transaction_id,
      ttl: Config.eb_ttl()
    }
  end

  defp unique_id do
    UUID.uuid4()
  end
end
