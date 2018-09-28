defmodule MessengerBot.Web.Plug.AppIdentification do
  @moduledoc false

  ############################################################################
  # Plug implementation to identify Facebook App                             #
  ############################################################################

  alias MessengerBot.Config
  alias MessengerBot.Model.App
  alias MessengerBot.Model.Error
  alias MessengerBot.Web.Renderer
  alias Plug.Conn

  @behaviour Plug

  @doc false
  def init(opts) do
    opts
  end

  @doc false
  def call(conn, _) do
    case app(conn.path_info) do
      %App{id: _} = app ->
        Conn.put_private(conn, :app, app)

      _ ->
        error = %Error{code: :not_found, details: %{app: "not found"}}
        Renderer.send_error(conn, error)
    end
  end

  defp app(path_info) do
    path_info
    |> List.last()
    |> Config.app()
  end
end
