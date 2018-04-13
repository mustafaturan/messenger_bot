defmodule MessengerBot.Util.JSONTest do
  use ExUnit.Case
  alias MessengerBot.Util.JSON
  doctest JSON

  test ".encode" do
    result = JSON.encode(%SampleStruct{id: 1, name: "foo bar"})
    expected = {:ok, "{\"name\":\"foo bar\",\"id\":1}"}

    assert result == expected
  end

  test ".decode" do
    payload = "{\"name\":\"foo bar\",\"id\":1}"
    result = JSON.decode(payload)

    assert result == {:ok, %{"id" => 1, "name" => "foo bar"}}
  end
end
