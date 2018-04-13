defmodule MessengerBot.Client.Middleware.BearerAuth do
  @moduledoc false

  ############################################################################
  # Tesla Middleware implementation for Bearer Auth Headers                  #
  # Middleware doesn't block the call when auth token not found for page ref,#
  # it
  ############################################################################

  alias MessengerBot.Config

  @behaviour Tesla.Middleware

  def call(env, next, _opts) do
    case Keyword.get(env.query, :access_token) do
      nil -> continue_with_credentials_from_page_ref(env, next)

      token -> continue_with_auth_header(env, next, token)
    end
  end

  defp continue_with_credentials_from_page_ref(env, next) do
    case page_access_token(env.opts) do
      {:ok, token} -> continue_with_auth_header(env, next, token)

      {:error, reason} -> {:error, reason}
    end
  end

  defp page_access_token(opts) do
    app_id = Keyword.get(opts, :app_id, "")
    page_id = Keyword.get(opts, :page_id, "")

    case Config.page_access_token(app_id, page_id) do
      "" -> {:error, %{access_token: "Not found for app_id: #{app_id}, page_id: #{page_id}"}}
      val -> {:ok, val}
    end
  end

  defp continue_with_auth_header(env, next, token) do
    env
    |> Tesla.put_header("Authorization", "Bearer #{token}")
    |> Tesla.run(next)
  end
end
