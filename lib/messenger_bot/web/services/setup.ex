defmodule MessengerBot.Web.Service.Setup do
  @moduledoc """
  MessengerBot webhook setup handler
  """

  use EventBus.EventSource
  alias MessengerBot.Config

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
  @spec run(app(), messenger_webhook_setup_params()) :: res()
  def run(%{id: app_id, setup_token: setup_token}, params) do
    id = unique_id()

    EventSource.notify %{id: id, transaction_id: id, topic: @topic, ttl: Config.eb_ttl()} do
      {status, params} = verify_token(verify_params(params), setup_token)
      {status, Map.put(params, :app_id, app_id)}
    end
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
    UUID.uuid4()
  end
end
