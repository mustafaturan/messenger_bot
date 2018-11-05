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
    case fetch_access_token_from_env(env) do
      {_, nil} ->
        continue_with_credentials_from_page_ref(env, next)

      {env, token} ->
        continue_with_auth_header(env, next, token)
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

  defp fetch_access_token_from_env(env) do
    case fetch_access_token_from_query(env) do
      {_, nil} -> fetch_access_token_from_body(env)

      env_with_access_token -> env_with_access_token
    end
  end

  defp fetch_access_token_from_query(env) do
    case remove_access_token_from_query(env.query) do
      {_, nil} -> {env, nil}

      {query, access_token} -> {Map.put(env, :query, query), access_token}
    end
  end

  defp fetch_access_token_from_body(env) do
    case remove_access_token_from_body(env.body) do
      {_, nil} -> {env, nil}

      {body, access_token} -> {Map.put(env, :body, body), access_token}
    end
  end

  defp remove_access_token_from_query(query) do
    {Keyword.delete(query, :access_token), Keyword.get(query, :access_token)}
  end

  defp remove_access_token_from_body(%{access_token: access_token} = body) do
    {Map.delete(body, :access_token), access_token}
  end

  defp remove_access_token_from_body(body) do
    {body, nil}
  end
end
