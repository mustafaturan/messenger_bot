defmodule MessengerBot.Model.PageTest do
  use ExUnit.Case, async: true
  alias MessengerBot.Model.Page

  doctest Page

  test "keys" do
    expected_keys = [:__struct__, :access_token, :app_id, :id, :metadata, :name, :token_expires_at]
    assert Map.keys(%Page{id: nil, access_token: nil}) == expected_keys
  end
end
