defmodule MessengerBot.Model.PageTest do
  use ExUnit.Case, async: true
  alias MessengerBot.Model.Page

  doctest Page

  test "keys" do
    expected_keys = [:__struct__, :access_token, :access_token_expires_at, :app_id, :id, :metadata, :name]
    assert Map.keys(%Page{id: nil, access_token: nil}) == expected_keys
  end
end
