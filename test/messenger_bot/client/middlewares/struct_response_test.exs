defmodule MessengerBot.Client.Middleware.StructResponseTest do
  use ExUnit.Case, async: false

  defmodule Client do
    use Tesla

    plug MessengerBot.Client.Middleware.StructResponse

    adapter fn env ->
      case env.url do
        "/" -> {:ok, %{status: 200, body: "{\"id\": 123456}"}}
        "/404" -> {:ok, %{status: 404, body: "{\"status\": \"not found\"}"}}
        "/na" -> {:error, :econnrefused}
      end
    end
  end

  describe "StructResponse" do
    test "returns success tuple when HTTP call succeeded with 200 status" do
      assert Client.get("/") == {:ok, "{\"id\": 123456}"}
    end

    test "returns error tuple when HTTP call failed with non 200 status" do
      assert Client.get("/404") == {:error, "{\"status\": \"not found\"}"}
    end

    test "returns error tuple when HTTP client error" do
      assert Client.get("/na") == {:error, %{error: :econnrefused}}
    end
  end
end
