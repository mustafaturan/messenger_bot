defmodule MessengerBot.Web.Router do
  @moduledoc false

  ############################################################################
  # Router for messenger webhooks                                            #
  ############################################################################

  use Plug.Router

  alias MessengerBot.Model.Error
  alias MessengerBot.Web.Controller.Messenger
  alias MessengerBot.Web.Plug.{AppAuthentication, AppIdentification, EventBus, MaxBodyLength, Transaction}
  alias MessengerBot.Web.Renderer

  plug(Transaction)
  plug(EventBus)
  plug(MaxBodyLength)
  plug(AppIdentification)
  plug(AppAuthentication)
  plug(:match)
  plug(:dispatch)

  ############################################################################
  # All Facebook Messenger webhook events will hit to this endpoint
  # POST /:app_id
  ############################################################################
  post _, do: Messenger.callback(conn)

  ############################################################################
  # Facebook Messenger Bot setup will hit to this endpoint
  # GET /:app_id
  ############################################################################
  get _, do: Messenger.setup(conn)

  ############################################################################
  # 404 response to all other routes
  # HEAD, GET, POST, PUT, PATCH, DELETE, OPTIONS /(.+)
  ############################################################################
  match _, do: Renderer.send_error(conn, not_found())

  defp not_found do
    %Error{code: :not_found, details: %{page: "Not found!"}}
  end
end
