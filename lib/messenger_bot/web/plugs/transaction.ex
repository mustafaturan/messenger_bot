defmodule MessengerBot.Web.Plug.Transaction do
  @moduledoc false

  ############################################################################
  # Plug implementation to add unique transaction identifier to each requests#
  ############################################################################

  alias Plug.Conn

  @behaviour Plug

  @doc false
  def init(opts) do
    opts
  end

  @doc false
  def call(conn, _opts) do
    Conn.put_private(conn, :tx_id, UUID.uuid4())
  end
end
