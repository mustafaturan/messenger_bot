defmodule MessengerBot.Client.Middleware.EventBus do
  @moduledoc false

  ############################################################################
  # Tesla Middleware implementation for EventBus notifications               #
  ############################################################################

  alias EventBus.Model.Event
  alias MessengerBot.Config
  alias MessengerBot.Util.String, as: StringUtil

  @behaviour Tesla.Middleware
  @base_url "https://graph.facebook.com"

  def call(env, next, _opts) do
    params = init_params()
    {time, response} = :timer.tc(Tesla, :run, [env, next])

    params
    |> Map.put(:occurred_at, params[:initialized_at] + time)
    |> Map.put(:data, data(env, response))
    |> Map.put(:topic, topic(Keyword.get(env.opts, :eb_topic), response))
    |> Map.put(:transaction_id, Keyword.get(env.opts, :eb_tx_id))
    |> Map.put(:ttl, Config.eb_ttl())
    |> notify()

    response
  end

  defp notify(params) do
    Event
    |> struct(params)
    |> EventBus.notify()
  end

  defp init_params do
    %{
      id: unique_id(),
      initialized_at: System.os_time(:microsecond),
      source: "MessengerBot.Client"
    }
  end

  defp topic(eb_topic, {:ok, %{status: 200}}) do
    String.to_atom("#{eb_topic}_succeeded")
  end

  defp topic(eb_topic, {:ok, _}) do
    String.to_atom("#{eb_topic}_failed")
  end

  defp topic(eb_topic, {:error, _}) do
    String.to_atom("#{eb_topic}_erred")
  end

  defp data(request, response) do
    %{
      app_id: Keyword.get(request.opts, :app_id),
      page_id: Keyword.get(request.opts, :page_id),
      request: prepare_request(request),
      response: prepare_response(response)
    }
  end

  defp prepare_request(request) do
    request
    |> Map.take([:body, :headers, :method, :query])
    |> Map.put(:path, String.replace(request.url, @base_url, ""))
  end

  defp prepare_response({:ok, response}) do
    Map.take(response, [:body, :headers, :status])
  end

  defp prepare_response({:error, error}) do
    %{error: error}
  end

  defp unique_id do
    StringUtil.unique_id()
  end
end
