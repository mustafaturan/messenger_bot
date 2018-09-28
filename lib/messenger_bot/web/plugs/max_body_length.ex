defmodule MessengerBot.Web.Plug.MaxBodyLength do
  @moduledoc false

  ############################################################################
  # Plug implementation to extract raw request body                          #
  ############################################################################

  alias MessengerBot.Model.Error
  alias MessengerBot.Web.Renderer
  alias Plug.Conn

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
        error = %Error{code: 422, details: %{body: "is bigger than expected"}}
        conn = Renderer.send_error(conn, error)

        {:error, {conn, nil}}
    end
  end

  defp assign_body({status, {conn, body}}) do
    case status do
      :ok ->
        Conn.put_private(conn, :body, body)

      :error ->
        conn
    end
  end
end
