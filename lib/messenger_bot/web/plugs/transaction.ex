defmodule MessengerBot.Web.Plug.Transaction do
  @moduledoc false

  ############################################################################
  # Plug implementation to add unique transaction identifier to each requests#
  ############################################################################

  alias MessengerBot.Util.String, as: StringUtil
  alias Plug.Conn

  @behaviour Plug

  @doc false
  def init(opts) do
    opts
  end

  @doc false
  def call(conn, _opts) do
    tx_id = Conn.get_req_header(conn, "x-request-id")
    tx_id = if Enum.empty?(tx_id), do: unique_id(), else: List.first(tx_id)
    Conn.put_private(conn, :tx_id, tx_id)
  end

  defp unique_id do
    StringUtil.unique_id()
  end
end
