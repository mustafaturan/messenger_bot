defmodule MessengerBot.Web.Service.Setup.TokenValidator do
  @moduledoc false

  alias MessengerBot.Model.{App, Error}
  alias MessengerBot.Web.Service.Setup.Params

  @spec validate(App.t(), Params.t()) :: {:ok, Params.t()} | Error.t()
  def validate(%App{} = app, %Params{} = params) do
    verify_token = params.verify_token
    if verify_token == app.setup_token do
      {:ok, params}
    else
      %Error{
        app_id: app.id,
        code: :unauthorized,
        details: %{verify_token: "Token(#{verify_token}) is not valid!"}
      }
    end
  end
end
