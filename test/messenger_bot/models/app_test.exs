defmodule MessengerBot.Model.AppTest do
  use ExUnit.Case, async: true
  alias MessengerBot.Model.App

  doctest App

  test "keys" do
    expected_keys = [:__struct__, :access_token, :id, :metadata, :name, :secret, :setup_token]
    assert Map.keys(%App{id: nil, secret: nil, setup_token: nil}) == expected_keys
  end
end
