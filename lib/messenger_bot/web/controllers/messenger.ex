defmodule MessengerBot.Web.Controller.Messenger do
  @moduledoc false

  import MessengerBot.Web.Controller.Base

  alias Plug.Conn
  alias MessengerBot.Web.Renderer
  alias MessengerBot.Web.Service.{Callback, Setup}

  @doc """
  Facebook Messenger Platform Setup handler
  """
  @spec setup(Conn.t()) :: no_return()
  def setup(conn) do
    case run_setup(conn) do
      {:ok, %{"hub.challenge" => challenge}} ->
        Renderer.send_ok(conn, challenge)

      {status, reason} ->
        Renderer.send_error(conn, {status, reason})
    end
  end

  @doc """
  Facebook Messenger Platform Webhook handler

  WARNING: 'checkout_update' and 'payment_pre_checkout' events are anti-pattern
  for this approach which require special response data. Thus, this package
  doesn't support the 'checkout_update' and 'payment_pre_checkout' events.
  """
  def callback(conn) do
    conn
    |> run_callback()
    |> Renderer.send_ok()
  end

  ############################################################################
  # PRIVATE                                                                  #
  ############################################################################

  @spec run_setup(Conn.t()) :: no_return()
  defp run_setup(conn) do
    app = Map.get(conn.private, :app)
    Setup.run(app, query_params(conn))
  end

  defp run_callback(conn) do
    params = [:app, :body, :tx_id]
    %{app: app, body: body, tx_id: tx_id} = Map.take(conn.private, params)
    spawn(fn -> Callback.run(app.id, body, tx_id) end)

    conn
  end
end
