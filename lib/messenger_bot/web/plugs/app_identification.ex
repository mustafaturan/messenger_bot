defmodule MessengerBot.Web.Plug.AppIdentification do
  @moduledoc false

  ############################################################################
  # Plug implementation to identify Facebook App                             #
  ############################################################################

  alias Plug.Conn
  alias MessengerBot.Config
  alias MessengerBot.Model.App
  alias MessengerBot.Web.Renderer

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
        Renderer.send_error(conn, {:not_found, %{app: "not found"}})
    end
  end

  defp app(path_info) do
    path_info
    |> List.last()
    |> Config.app()
  end
end
