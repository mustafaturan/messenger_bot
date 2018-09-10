defmodule MessengerBot.Util.JSONTest do
  use ExUnit.Case

  alias MessengerBot.Util.JSON

  doctest JSON

  test ".encode nil" do
    result = JSON.encode(nil)
    expected = {:ok, nil}

    assert result == expected
  end

  test ".encode" do
    result = JSON.encode(%{id: 1, name: "foo bar"})
    expected = {:ok, "{\"name\":\"foo bar\",\"id\":1}"}

    assert result == expected
  end

  test ".encode!" do
    result = JSON.encode!(%{id: 1, name: "foo bar"})
    expected = "{\"name\":\"foo bar\",\"id\":1}"

    assert result == expected
  end

  test ".decode" do
    payload = "{\"name\":\"foo bar\",\"id\":1}"
    result = JSON.decode(payload)

    assert result == {:ok, %{"id" => 1, "name" => "foo bar"}}
  end
end
