defmodule MessengerBot.Web.Service.SetupTest do
  use ExUnit.Case
  alias MessengerBot.Web.Service.Setup
  alias MessengerBot.Config

  doctest Setup

  @app_id "1881"

  setup do
    {:ok, app: Config.app(@app_id)}
  end

  test "#run with valid params", %{app: app} do
    params = %{
      "hub.challenge" => "icebucket",
      "hub.mode" => "subscribe",
      "hub.verify_token" => app.setup_token
    }
    result = Setup.run(app, params)
    assert result == {:ok, Map.put(params, :app_id, app.id)}
  end

  test "#run with missing params", %{app: app} do
    result = Setup.run(app, %{"hub.mode" => "", "hub.verify_token" => ""})
    expected_payload = %{missing_params: ["hub.challenge"], app_id: app.id}
    assert result == {:unprocessable_entity, expected_payload}
  end

  test "#run with valid params, but invalid token", %{app: app} do
    params = %{
      "hub.challenge" => "icebucket",
      "hub.mode" => "unsubscribe",
      "hub.verify_token" => "wrongone"
    }
    result = Setup.run(app, params)
    expected_payload = %{"hub.verify_token": "Token(wrongone) is not valid!", app_id: app.id}
    assert result == {:unauthorized, expected_payload}
  end
end
