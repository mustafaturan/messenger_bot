defmodule MessengerBot.Client.Middleware.StructResponse do
  @moduledoc false

  ############################################################################
  # Tesla Middleware implementation to structure the response                #
  ############################################################################

  @behaviour Tesla.Middleware

  def call(env, next, _opts) do
    response = Tesla.run(env, next)
    struct_response(response)
  end

  defp struct_response({:ok, %{status: 200} = response}) do
    {:ok, response.body}
  end

  defp struct_response({:ok, %{status: _} = response}) do
    {:error, response.body}
  end

  defp struct_response({:error, error}) do
    {:error, %{error: error}}
  end
end
