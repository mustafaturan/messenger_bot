defmodule MessengerBot.Web.Service.SetupTest do
  use ExUnit.Case

  alias MessengerBot.Config
  alias MessengerBot.Model.Error
  alias MessengerBot.Web.Service.Setup
  alias MessengerBot.Web.Service.Setup.Params

  doctest Setup

  @app_id "1881"
  @transaction_id "xyz"

  setup do
    {:ok, app: Config.app(@app_id)}
  end

  test "#run with valid params", %{app: app} do
    params = %{
      "hub.challenge" => "icebucket",
      "hub.mode" => "subscribe",
      "hub.verify_token" => app.setup_token
    }
    expected_payload = %Params{
      app_id: "1881",
      challenge: "icebucket",
      mode: "subscribe",
      verify_token: app.setup_token
    }
    result = Setup.run(app, params, @transaction_id)
    assert result == {:ok, expected_payload}
  end

  test "#run with missing params", %{app: app} do
    expected_payload = %Error{
      app_id: @app_id,
      code: :unprocessable_entity,
      details: %{missing_params: ["hub.challenge", "hub.verify_token"]}
    }
    result = Setup.run(app, %{"hub.mode" => ""}, @transaction_id)
    assert result == {:error, expected_payload}
  end

  test "#run with valid params, but invalid token", %{app: app} do
    params = %{
      "hub.challenge" => "icebucket",
      "hub.mode" => "unsubscribe",
      "hub.verify_token" => "wrongone"
    }
    expected_payload = %Error{
      app_id: @app_id,
      code: :unauthorized,
      details: %{verify_token: "Token(wrongone) is not valid!"}
    }
    result = Setup.run(app, params, @transaction_id)
    assert result == {:error, expected_payload}
  end
end
