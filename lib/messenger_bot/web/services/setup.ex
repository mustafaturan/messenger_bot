defmodule MessengerBot.Web.Service.Setup do
  @moduledoc """
  MessengerBot webhook setup handler
  """

  use EventBus.EventSource

  alias MessengerBot.Model.{App, Error}
  alias MessengerBot.Web.Service.Setup.Params
  alias MessengerBot.Web.Service.Setup.TokenValidator

  @type messenger_webhook_setup_params :: map()
  @type app :: App.t()
  @type failure :: {:error, Error.t()}
  @type success :: {:ok, Params.t()}
  @type res :: failure() | success()

  @topic :mb_app_setup_succeeded
  @error_topic :mb_app_setup_failed

  @doc """
  Process setup webhooks coming from Facebook Messenger Platform
  """
  @spec run(app(), messenger_webhook_setup_params(), String.t()) :: res()
  def run(%App{} = app, params, transaction_id) do
    EventSource.notify event_params(transaction_id) do
      execute_for(app, params)
    end
  end

  defp execute_for(app, params) do
    with {:ok, setup_params} <- build_params(app, params),
         {:ok, _} <- validate_app_token(app, setup_params) do
      {:ok, setup_params}
    else
      error -> {:error, error}
    end
  end

  defp build_params(app, params) do
    Params.build(app.id, params)
  end

  defp validate_app_token(app, setup_params) do
    TokenValidator.validate(app, setup_params)
  end

  defp event_params(transaction_id) do
    %{
      transaction_id: transaction_id,
      topic: @topic,
      error_topic: @error_topic
    }
  end
end
