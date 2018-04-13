defmodule MessengerBot.Web.Renderer do
  @moduledoc false

  import Plug.Conn
  alias MessengerBot.Util.JSON

  @doc """
  Send ok response
  """
  @spec send_ok(Conn.t()) :: no_return()
  def send_ok(conn, data \\ "[]") do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(:ok, data)
  end

  @doc """
  Send error response
  """
  @spec send_error(Conn.t(), {atom(), Map.t()}) :: no_return()
  def send_error(conn, {status, errors}) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, JSON.encode!(%{errors: errors}))
    |> halt()
  end
end
