defmodule MessengerBot.ApplicationTest do
  use ExUnit.Case, async: false

  test ".start with missing topics" do
    assert_raise RuntimeError, fn ->
      EventBus.unregister_topic(:mb_webserv_succeeded)
      MessengerBot.Application.start(nil, nil)
    end
  end
end
