defmodule MessengerBot.Web.Controller.Base do
  @moduledoc false

  alias Plug.Conn

  @doc """
  Fetch query params
  """
  @spec query_params(Conn.t()) :: map()
  def query_params(conn) do
    conn
    |> Conn.fetch_query_params()
    |> Map.get(:query_params, %{})
  end
end
