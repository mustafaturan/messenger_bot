defmodule MessengerBot.Web.Plug.EventBus do
  @moduledoc false

  ############################################################################
  # Plug implementation for EventBus notifications                           #
  ############################################################################

  alias Plug.Conn
  alias EventBus.Model.Event
  alias MessengerBot.Config

  @behaviour Plug

  @doc false
  def init(opts) do
    Keyword.get(opts, :topic_prefix, :mb_webserv)
  end

  @doc false
  def call(conn, topic_prefix) do
    params = init_params()

    Conn.register_before_send(conn, fn conn ->
      params
      |> Map.put(:occurred_at, now())
      |> Map.put(:data, data(conn))
      |> Map.put(:topic, :"#{topic_prefix}#{topic_suffix(conn.status)}")
      |> Map.put(:transaction_id, conn.private[:tx_id])
      |> Map.put(:ttl, Config.eb_ttl())
      |> notify()

      conn
    end)
  end

  defp notify(params) do
    Event
    |> struct(params)
    |> EventBus.notify()
  end

  defp data(conn) do
    %{
      app_id: Map.get(Map.get(conn.private, :app, %{}), :id),
      request: prepare_request(conn),
      response: prepare_response(conn)
    }
  end

  defp prepare_request(conn) do
    %{
      body: conn.private[:body],
      headers: conn.req_headers,
      path: conn.request_path,
      query: conn.query_string
    }
  end

  defp prepare_response(conn) do
    %{
      body: conn.resp_body,
      headers: conn.resp_headers,
      status: conn.status
    }
  end

  defp topic_suffix(status) when status < 400 do
    "_succeeded"
  end

  defp topic_suffix(status) when status >= 400 and status < 500 do
    "_payload_failed"
  end

  defp topic_suffix(status) when status >= 500 do
    "_erred"
  end

  defp init_params do
    %{
      id: unique_id(),
      initialized_at: now(),
      source: "Plug.EventBus"
    }
  end

  defp unique_id do
    UUID.uuid4()
  end

  defp now do
    System.os_time(:microseconds)
  end
end
