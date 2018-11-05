defmodule MessengerBot.Client.Middleware.BearerAuthTest do
  use ExUnit.Case, async: false

  defmodule Client do
    use Tesla

    plug MessengerBot.Client.Middleware.BearerAuth

    adapter fn env ->
      case env.url do
        "/" -> {:ok, env}
      end
    end
  end

  describe "BearerAuth" do
    test "adds header correctly" do
      {:ok, env} = Client.get("/", opts: [app_id: "1881", page_id: "1234"])
      auth_header = Tesla.get_header(env, "Authorization")
      assert auth_header == "Bearer accesstokenforpage"
    end

    test "adds header correctly from query" do
      {:ok, env} = Client.get("/", query: [access_token: "accesstokenforquery"], opts: [app_id: "1881", page_id: "1234"])
      auth_header = Tesla.get_header(env, "Authorization")
      assert auth_header == "Bearer accesstokenforquery"
    end

    test "remove access_token from query" do
      {:ok, env} = Client.get("/", query: [access_token: "accesstokenforquery", other: "ok"], opts: [app_id: "1881", page_id: "1234"])
      refute Keyword.get(env.query, :access_token)
      assert Keyword.get(env.query, :other)
    end

    test "adds header correctly from body" do
      {:ok, env} = Client.get("/", body: %{access_token: "accesstokenforbody"}, opts: [app_id: "1881", page_id: "1234"])
      auth_header = Tesla.get_header(env, "Authorization")
      assert auth_header == "Bearer accesstokenforbody"
    end

    test "remove access_token from body" do
      {:ok, env} = Client.get("/", body: %{access_token: "accesstokenforbody", other: "ok"}, opts: [app_id: "1881", page_id: "1234"])
      refute Map.get(env.body, :access_token)
      assert Map.get(env.body, :other)
    end

    test "return error when page_access_token not exist" do
      {:error, env} = Client.get("/", opts: [app_id: "1986", page_id: "1990"])
      assert env == %{access_token: "Not found for app_id: 1986, page_id: 1990"}
    end
  end
end
