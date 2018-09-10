defmodule MessengerBot.Web.Service.Setup do
  @moduledoc """
  MessengerBot webhook setup handler
  """

  use EventBus.EventSource

  alias MessengerBot.Util.String, as: StringUtil

  @type messenger_webhook_setup_params :: %{
          String.t() => String.t(),
          String.t() => String.t(),
          String.t() => String.t()
        } | Map.t()
  @type app :: Map.t()
  @type status :: :ok | :unprocessable_entity | :unauthorized
  @type res :: {status(), Map.t()}

  @topic :mb_app_setup_received
  @required_params ~w(hub.challenge hub.mode hub.verify_token)

  @doc """
  Process setup webhooks coming from Facebook Messenger Platform
  """
  @spec run(app(), messenger_webhook_setup_params()) :: no_return()
  def run(%{id: app_id, setup_token: setup_token}, params) do
    transaction_id = unique_id()
    event_params   = %{transaction_id: transaction_id, topic: @topic}

    {status, params} =
      EventSource.notify event_params do
        verified_params = verify_params(params)
        verify_token(verified_params, setup_token)
      end

    {status, Map.put(params, :app_id, app_id)}
  end

  defp verify_params(%{"hub.challenge" => _, "hub.mode" => _, "hub.verify_token" => _} = params) do
    {:ok, params}
  end

  defp verify_params(params) do
    missing_params = @required_params -- Map.keys(params)
    {:unprocessable_entity, %{missing_params: missing_params}}
  end

  defp verify_token({:ok, %{"hub.verify_token" => token} = params}, setup_token) do
    if setup_token == token do
      {:ok, params}
    else
      {:unauthorized, %{"hub.verify_token": "Token(#{token}) is not valid!"}}
    end
  end

  defp verify_token(bypass_data, _) do
    bypass_data
  end

  defp unique_id do
    StringUtil.unique_id()
  end
end
