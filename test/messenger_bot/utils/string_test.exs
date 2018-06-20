defmodule MessengerBot.Util.StringTest do
  use ExUnit.Case
  alias MessengerBot.Util.String, as: StringUtil
  doctest StringUtil

  test ".unique_id" do
    refute StringUtil.unique_id() == StringUtil.unique_id()
  end
end
