defmodule MessengerBot.Web.Controller.BaseTest do
  use ExUnit.Case, async: false
  alias MessengerBot.ConnHelper
  alias MessengerBot.Web.Controller.Base, as: BaseController

  doctest BaseController

  setup do
    {:ok, conn: ConnHelper.build_conn()}
  end

  test ".query_params with query string", %{conn: conn} do
    conn = Map.put(conn, :query_string, "foo=bar")
    assert BaseController.query_params(conn) == %{"foo" => "bar"}
  end

  test ".query_params without query string", %{conn: conn} do
    assert BaseController.query_params(conn) == %{}
  end
end
