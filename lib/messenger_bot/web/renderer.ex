defmodule MessengerBot.Web.Renderer do
  @moduledoc false

  import Plug.Conn

  alias MessengerBot.Model.Error
  alias MessengerBot.Util.JSON
  alias Plug.Conn

  @doc """
  Send ok response
  """
  @spec send_ok(Conn.t()) :: Conn.t()
  def send_ok(conn, data \\ "[]") do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(:ok, data)
    |> halt()
  end

  @doc """
  Send error response
  """
  @spec send_error(Conn.t(), Error.t()) :: Conn.t()
  def send_error(conn, error) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(error.code, JSON.encode!(%{errors: error.details}))
    |> halt()
  end
end
