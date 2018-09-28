defmodule MessengerBot.Web.Controller.Messenger do
  @moduledoc false

  import MessengerBot.Web.Controller.Base

  alias MessengerBot.Web.Renderer
  alias MessengerBot.Web.Service.{Callback, Setup}
  alias Plug.Conn

  @doc """
  Facebook Messenger Platform Setup handler
  """
  @spec setup(Conn.t()) :: Conn.t()
  def setup(conn) do
    case run_setup(conn) do
      {:ok, setup_params} ->
        Renderer.send_ok(conn, setup_params.challenge)

      {:error, error} ->
        Renderer.send_error(conn, error)
    end
  end

  @doc """
  Facebook Messenger Platform Webhook handler

  WARNING: 'checkout_update' and 'payment_pre_checkout' events are anti-pattern
  for this approach which require special response data. Thus, this package
  doesn't support the 'checkout_update' and 'payment_pre_checkout' events.
  """
  @spec callback(Conn.t()) :: Conn.t()
  def callback(conn) do
    conn
    |> run_callback()
    |> Renderer.send_ok()
  end

  ############################################################################
  # PRIVATE                                                                  #
  ############################################################################

  defp run_setup(conn) do
    params = [:app, :tx_id]
    %{app: app, tx_id: tx_id} = Map.take(conn.private, params)
    Setup.run(app, query_params(conn), tx_id)
  end

  defp run_callback(conn) do
    params = [:app, :body, :tx_id]
    %{app: app, body: body, tx_id: tx_id} = Map.take(conn.private, params)
    spawn(fn -> Callback.run(app.id, body, tx_id) end)

    conn
  end
end
