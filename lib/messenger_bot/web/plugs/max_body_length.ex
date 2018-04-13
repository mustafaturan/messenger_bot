defmodule MessengerBot.Web.Plug.MaxBodyLength do
  @moduledoc false

  ############################################################################
  # Plug implementation to extract raw request body                          #
  ############################################################################

  alias Plug.Conn
  alias MessengerBot.Web.Renderer

  @behaviour Plug
  @max_body_length 128_000

  @doc false
  def init(opts) do
    opts
  end

  @doc false
  def call(%{method: "POST"} = conn, _opts) do
    conn
    |> limit_body_length()
    |> assign_body()
  end

  def call(conn, _) do
    conn
  end

  defp limit_body_length(conn) do
    case Conn.read_body(conn, length: @max_body_length) do
      {:ok, body, conn} ->
        {:ok, {conn, body}}

      _ ->
        conn =
          Renderer.send_error(conn, {422, %{body: "is bigger than expected"}})

        {:error, {conn, nil}}
    end
  end

  defp assign_body({:ok, {conn, body}}) do
    Conn.put_private(conn, :body, body)
  end

  defp assign_body({:error, {conn, nil}}) do
    conn
  end
end
