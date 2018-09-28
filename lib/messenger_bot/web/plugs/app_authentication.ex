defmodule MessengerBot.Web.Plug.AppAuthentication do
  @moduledoc false

  ############################################################################
  # Plug implementation to verify the sha1 signature with request body       #
  ############################################################################

  alias MessengerBot.Model.Error
  alias MessengerBot.Util.Encryption
  alias MessengerBot.Web.Renderer
  alias Plug.Conn

  @behaviour Plug

  @doc false
  def init(opts) do
    opts
  end

  @doc false
  def call(%{method: "POST"} = conn, _opts) do
    %{app: app, body: body} = Map.take(conn.private, [:app, :body])

    case fetch_signature(conn) do
      ["sha1=" <> signature] ->
        case Encryption.validate_sha1(app.secret, body, signature) do
          :ok ->
            conn

          {:error, error} ->
            error = %Error{app_id: app.id, code: :unauthorized, details: error}
            Renderer.send_error(conn, error)
        end

      _ ->
        error = %Error{app_id: app.id, code: :unauthorized, details: %{signature: "required"}}
        Renderer.send_error(conn, error)
    end
  end

  def call(conn, _) do
    conn
  end

  defp fetch_signature(conn) do
    Conn.get_req_header(conn, "x-hub-signature")
  end
end
