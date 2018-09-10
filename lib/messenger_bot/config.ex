defmodule MessengerBot.Config do
  @moduledoc """
  App configurations
  """

  alias MessengerBot.Model.{App, Page}

  @app :messenger_bot

  @typep app_id :: String.t()
  @typep app :: App.t()
  @typep app_list :: Map.t()
  @typep page :: Page.t()
  @typep page_id :: String.t()
  @typep page_list :: Map.t()
  @typep ttl :: integer()
  @typep str_token :: String.t()

  @doc """
  EventBus topic ttl for MessengerBot events default is 900_000_000 microseconds
  """
  @spec eb_ttl() :: ttl()
  def eb_ttl do
    Application.get_env(@app, :eb_ttl, 900_000_000)
  end

  @doc """
  Messenger Setup Token
  """
  @spec app_setup_token(app_id()) :: str_token()
  def app_setup_token(app_id) do
    app_id
    |> app()
    |> Map.get(:setup_token, "")
  end

  @doc """
  Messenger App Access Token
  """
  @spec app_access_token(app_id()) :: str_token()
  def app_access_token(app_id) do
    app_id
    |> app()
    |> Map.get(:access_token, "")
  end

  @doc """
  Messenger App Secret
  """
  @spec app_secret(app_id()) :: str_token()
  def app_secret(app_id) do
    app_id
    |> app()
    |> Map.get(:secret, "")
  end

  @doc """
  Messenger App
  """
  @spec app(app_id()) :: app() | Map.t()
  def app(app_id) do
    to_app(Map.get(apps(), app_id))
  end

  @doc """
  Messenger Apps
  """
  @spec apps() :: app_list() | list(Map.t())
  def apps do
    Application.get_env(@app, :apps, %{})
  end

  @doc """
  Facebook Page Token
  """
  @spec page_access_token(app_id(), page_id()) :: str_token()
  def page_access_token(app_id, page_id) do
    app_id
    |> page(page_id)
    |> Map.get(:access_token, "")
  end

  @doc """
  Facebook Page
  """
  @spec page(app_id(), page_id()) :: page() | Map.t()
  def page(app_id, page_id) do
    app_id
    |> pages()
    |> Map.get(page_id)
    |> to_page()
  end

  @doc """
  Facebook Page map for an app
  """
  @spec pages(app_id()) :: page_list() | list(Map.t())
  def pages(app_id) do
    Map.get(pages(), app_id, %{})
  end

  @doc """
  Facebook Page map grouped by app_id
  """
  @spec pages() :: page_list()
  def pages do
    Application.get_env(@app, :pages, %{})
  end

  @doc """
  Save Facebook Page map for an app_id
  Note: Map *keys* for each page MUST be type of atom()
  """
  @spec save_pages(app_id(), page_list()) :: :ok
  def save_pages(app_id, app_pages) do
    pages = Map.put(pages(), app_id, app_pages)
    Application.put_env(@app, :pages, pages)
  end

  @doc """
  Save Messenger App map to config
  Note: Map *keys* for each app MUST be type of atom()
  """
  def save_apps(apps) do
    Application.put_env(@app, :apps, apps)
  end

  ###########################################################################
  # PRIAVTE                                                                 #
  ###########################################################################

  defp to_app(%{__struct__: _} = app) do
    app
  end

  defp to_app(%{} = app) do
    struct(App, app)
  end

  defp to_app(nil) do
    %{}
  end

  defp to_page(%{__struct__: _} = page) do
    page
  end

  defp to_page(%{} = page) do
    struct(Page, page)
  end

  defp to_page(nil) do
    %{}
  end
end
