defmodule MessengerBot.ConfigTest do
  use ExUnit.Case, async: true
  alias MessengerBot.Config
  alias MessengerBot.Model.{App, Page}

  doctest Config

  @app_id "1881"
  @page_id "1234"
  @app %{
    id: "1881",
    secret: "SECRET",
    setup_token: "Setup Token",
    access_token: "ATOKEN123"
  }
  @page %{
    id: "1234",
    name: "Demo Facebook Messenger Bot",
    access_token: "accesstokenforpage"
  }

  setup do
    Config.save_apps(%{@app_id => @app})
    Config.save_pages(@app_id, %{@page_id => @page})
    :ok
  end

  test ".eb_ttl" do
    assert Config.eb_ttl == 900_000_000
  end

  test ".app_setup_token" do
    assert Config.app_setup_token(@app_id) == "Setup Token"
  end

  test ".app_access_token" do
    assert Config.app_access_token(@app_id) == "ATOKEN123"
  end

  test ".app_secret" do
    assert Config.app_secret(@app_id) == "SECRET"
  end

  test ".app" do
    assert Config.app(@app_id) == struct(App, @app)
  end

  test ".apps" do
    assert Config.apps() == %{@app_id => @app}
  end

  test ".page" do
    assert Config.page(@app_id, @page_id) == struct(Page, @page)
  end

  test ".pages" do
    assert Config.pages(@app_id) == %{@page_id => @page}
  end

  test ".save_pages" do
    another_page = struct(Page, Map.put(@page, :id, "1235"))
    pages = %{@page_id => @page, "1235" => another_page}
    assert Config.save_pages(@app_id, pages) == :ok
    assert Config.pages(@app_id) == pages
    assert Config.page(@app_id, "1235") == another_page
  end

  test ".save_apps" do
    another_app = struct(App, Map.put(@app, :id, "1986"))
    apps = %{@app_id => @app, "1986" => another_app}
    assert Config.save_apps(apps) == :ok
    assert Config.apps() == apps
    assert Config.app("1986") == another_app
  end
end
