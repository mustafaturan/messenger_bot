defmodule MessengerBot.Client.Base do
  @moduledoc false

  ############################################################################
  # MessengerBot Client core implementation                                  #
  ############################################################################

  use Tesla, only: ~w(get post delete)a
  alias MessengerBot.Util.JSON
  alias MessengerBot.Util.String, as: StringUtil

  plug Tesla.Middleware.BaseUrl, "https://graph.facebook.com"
  plug MessengerBot.Client.Middleware.BearerAuth
  plug MessengerBot.Client.Middleware.StructResponse
  plug Tesla.Middleware.JSON, decode: &JSON.decode/1, encode: &JSON.encode/1
  plug MessengerBot.Client.Middleware.EventBus

  @api_version "v2.12"

  def rget(path, query_params, opts) do
    get(
      full_path(path),
      query: query_params,
      opts: opts_with_keys(opts)
    )
  end

  def rpost(path, req, opts) do
    post(
      full_path(path),
      req,
      opts: opts_with_keys(opts)
    )
  end

  def rdelete(path, req, opts) do
    delete(
      full_path(path),
      body: req,
      opts: opts_with_keys(opts)
    )
  end

  ############################################################################
  # PRIVATE                                                                  #
  ############################################################################

  defp full_path(path) do
    "/#{@api_version}#{path}"
  end

  defp opts_with_keys({app_id, page_id, topic, tx_id}) do
    tx_id = if is_nil(tx_id), do: unique_id(), else: tx_id
    [app_id: app_id, page_id: page_id, eb_topic: topic, eb_tx_id: tx_id]
  end

  defp unique_id do
    StringUtil.unique_id()
  end
end
